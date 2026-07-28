import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/exercise_media.dart';
import 'exercise_media_downloader.dart';

ExerciseMediaDownloader createExerciseMediaDownloader() =>
    MobileExerciseMediaDownloader();

class MobileExerciseMediaDownloader implements ExerciseMediaDownloader {
  @override
  bool get isSupported => true;

  @override
  Future<DownloadedExerciseMedia> download(
    ExerciseMedia media, {
    required ExerciseDownloadProgress onProgress,
  }) async {
    if (!media.hasVideo) {
      throw const StateError('این حرکت ویدئوی قابل دانلود ندارد.');
    }

    final Directory root = await getApplicationDocumentsDirectory();
    final Directory directory = Directory(
      p.join(root.path, 'coach_media', 'exercise_videos'),
    );
    await directory.create(recursive: true);

    final String extension = _safeExtension(Uri.parse(media.videoUrl).path);
    final String fileName = '${_safeName(media.exerciseId)}_v${media.version}$extension';
    final File destination = File(p.join(directory.path, fileName));
    final File temporary = File('${destination.path}.part');
    if (await temporary.exists()) {
      await temporary.delete();
    }

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(media.videoUrl));
      request.headers.set(HttpHeaders.acceptHeader, 'video/mp4,video/*;q=0.9,*/*;q=0.1');
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'دانلود ویدئو با خطای HTTP ${response.statusCode} متوقف شد.',
          uri: Uri.parse(media.videoUrl),
        );
      }

      final IOSink sink = temporary.openWrite();
      int received = 0;
      final int? total = response.contentLength > 0 ? response.contentLength : null;
      try {
        await for (final List<int> chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          onProgress(received, total);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      if (received == 0) {
        throw const FileSystemException('فایل ویدئو خالی دریافت شد.');
      }
      if (total != null && received != total) {
        throw FileSystemException(
          'دانلود ناقص بود: $received از $total بایت دریافت شد.',
        );
      }
      if (await destination.exists()) {
        await destination.delete();
      }
      await temporary.rename(destination.path);
      return DownloadedExerciseMedia(
        localPath: destination.path,
        fileSizeBytes: received,
      );
    } catch (_) {
      if (await temporary.exists()) {
        await temporary.delete();
      }
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<bool> exists(String localPath) async =>
      localPath.isNotEmpty && File(localPath).existsSync();

  @override
  Future<void> delete(String localPath) async {
    if (localPath.isEmpty) {
      return;
    }
    final File file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _safeName(String value) => value.replaceAll(
    RegExp(r'[^a-zA-Z0-9_-]'),
    '_',
  );

  String _safeExtension(String path) {
    final String extension = p.extension(path).toLowerCase();
    return <String>{'.mp4', '.m4v', '.mov', '.webm'}.contains(extension)
        ? extension
        : '.mp4';
  }
}
