import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/exercise_media.dart';
import 'exercise_video_store_base.dart';

ExerciseVideoStore createExerciseVideoStore() => MobileExerciseVideoStore();

class MobileExerciseVideoStore implements ExerciseVideoStore {
  @override
  bool get canDownload => true;

  @override
  Future<ExerciseVideoDownload?> locate(ExerciseMedia media) async {
    final File file = await _targetFile(media);
    if (!await file.exists()) {
      return null;
    }
    final int bytes = await file.length();
    if (media.sizeBytes case final int expected when expected > 0) {
      if (bytes != expected) {
        await file.delete();
        return null;
      }
    }
    return ExerciseVideoDownload(
      exerciseId: media.exerciseId,
      mediaVersion: media.version,
      localPath: file.path,
      bytes: bytes,
      downloadedAt: (await file.lastModified()).toUtc(),
    );
  }

  @override
  Future<ExerciseVideoDownload> download(
    ExerciseMedia media, {
    DownloadProgress? onProgress,
  }) async {
    if (!media.hasVideo) {
      throw const FormatException('آدرس ویدیوی حرکت معتبر نیست.');
    }

    final Directory directory = await _videoDirectory();
    final File target = await _targetFile(media);
    final File temporary = File('${target.path}.part');
    if (await temporary.exists()) {
      await temporary.delete();
    }

    final http.Client client = http.Client();
    IOSink? output;
    try {
      final http.Request request = http.Request(
        'GET',
        Uri.parse(media.fullVideoUrl),
      );
      final http.StreamedResponse response = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Video download returned HTTP ${response.statusCode}.',
          uri: Uri.parse(media.fullVideoUrl),
        );
      }

      output = temporary.openWrite();
      int received = 0;
      final int? total = response.contentLength ?? media.sizeBytes;
      await for (final List<int> chunk in response.stream) {
        output.add(chunk);
        received += chunk.length;
        if (total != null && total > 0) {
          onProgress?.call(
            (received / total).clamp(0.0, 1.0).toDouble(),
          );
        }
      }
      await output.flush();
      await output.close();
      output = null;

      if (media.sizeBytes case final int expected when expected > 0) {
        if (received != expected) {
          throw StateError(
            'حجم ویدیوی دریافت‌شده با اطلاعات کتابخانه تطابق ندارد.',
          );
        }
      }

      if (media.sha256.isNotEmpty) {
        final String digest = sha256
            .convert(await temporary.readAsBytes())
            .toString()
            .toLowerCase();
        if (digest != media.sha256) {
          throw StateError('صحت فایل ویدیویی تأیید نشد.');
        }
      }

      if (await target.exists()) {
        await target.delete();
      }
      await temporary.rename(target.path);
      await _deleteOtherVersions(directory, media, keepPath: target.path);
      onProgress?.call(1);
      return ExerciseVideoDownload(
        exerciseId: media.exerciseId,
        mediaVersion: media.version,
        localPath: target.path,
        bytes: received,
        downloadedAt: DateTime.now().toUtc(),
      );
    } catch (_) {
      await output?.close();
      if (await temporary.exists()) {
        await temporary.delete();
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  @override
  Future<void> delete(ExerciseMedia media) async {
    final Directory directory = await _videoDirectory();
    final String prefix = '${_safeId(media.exerciseId)}_v';
    await for (final FileSystemEntity entity in directory.list()) {
      if (entity is File && p.basename(entity.path).startsWith(prefix)) {
        await entity.delete();
      }
    }
  }

  Future<File> _targetFile(ExerciseMedia media) async {
    final Directory directory = await _videoDirectory();
    return File(
      p.join(directory.path, '${_safeId(media.exerciseId)}_v${media.version}.mp4'),
    );
  }

  Future<Directory> _videoDirectory() async {
    final Directory support = await getApplicationSupportDirectory();
    final Directory directory = Directory(
      p.join(support.path, 'exercise_videos'),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<void> _deleteOtherVersions(
    Directory directory,
    ExerciseMedia media, {
    required String keepPath,
  }) async {
    final String prefix = '${_safeId(media.exerciseId)}_v';
    await for (final FileSystemEntity entity in directory.list()) {
      if (entity is File &&
          entity.path != keepPath &&
          p.basename(entity.path).startsWith(prefix)) {
        await entity.delete();
      }
    }
  }

  String _safeId(String value) => value.replaceAll(
    RegExp('[^a-zA-Z0-9_-]'),
    '_',
  );
}
