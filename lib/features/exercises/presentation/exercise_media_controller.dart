import 'package:flutter/foundation.dart';

import '../data/exercise_catalog_client.dart';
import '../data/exercise_media_downloader.dart';
import '../data/exercise_media_repository.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';
import '../domain/exercise_media.dart';

class ExerciseMediaController extends ChangeNotifier {
  ExerciseMediaController({
    required ExerciseRepository exerciseRepository,
    required ExerciseMediaRepository mediaRepository,
    required ExerciseMediaDownloader downloader,
    ExerciseCatalogClient? catalogClient,
  }) : _exerciseRepository = exerciseRepository,
       _mediaRepository = mediaRepository,
       _downloader = downloader,
       _catalogClient = catalogClient ?? ExerciseCatalogClient();

  final ExerciseRepository _exerciseRepository;
  final ExerciseMediaRepository _mediaRepository;
  final ExerciseMediaDownloader _downloader;
  final ExerciseCatalogClient _catalogClient;

  Map<String, ExerciseMedia> _media = <String, ExerciseMedia>{};
  Map<String, ExerciseMediaDownload> _downloads =
      <String, ExerciseMediaDownload>{};
  final Set<String> _downloading = <String>{};
  final Map<String, double?> _progress = <String, double?>{};

  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;
  DateTime? _lastSyncedAt;

  Map<String, ExerciseMedia> get media =>
      Map<String, ExerciseMedia>.unmodifiable(_media);
  Map<String, ExerciseMediaDownload> get downloads =>
      Map<String, ExerciseMediaDownload>.unmodifiable(_downloads);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get canDownload => _downloader.isSupported;
  bool get canSync => _catalogClient.isConfigured;
  Object? get error => _error;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  ExerciseMedia? mediaFor(String exerciseId) => _media[exerciseId];

  ExerciseMediaDownload? downloadFor(String exerciseId) {
    final ExerciseMedia? item = mediaFor(exerciseId);
    final ExerciseMediaDownload? download = _downloads[exerciseId];
    return item != null && download?.matches(item) == true ? download : null;
  }

  bool isDownloading(String exerciseId) => _downloading.contains(exerciseId);

  double? progressFor(String exerciseId) => _progress[exerciseId];

  ExerciseMediaDownloadState stateFor(String exerciseId) {
    if (isDownloading(exerciseId)) {
      return ExerciseMediaDownloadState.downloading;
    }
    if (downloadFor(exerciseId) != null) {
      return ExerciseMediaDownloadState.downloaded;
    }
    return ExerciseMediaDownloadState.notDownloaded;
  }

  Future<void> load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _media = await _mediaRepository.getAllMedia();
      final Map<String, ExerciseMediaDownload> stored = await _mediaRepository
          .getAllDownloads();
      final Map<String, ExerciseMediaDownload> valid =
          <String, ExerciseMediaDownload>{};
      for (final MapEntry<String, ExerciseMediaDownload> entry
          in stored.entries) {
        final ExerciseMedia? item = _media[entry.key];
        final bool fileExists = await _downloader.exists(entry.value.localPath);
        if (item != null && entry.value.matches(item) && fileExists) {
          valid[entry.key] = entry.value;
        } else {
          await _downloader.delete(entry.value.localPath);
          await _mediaRepository.deleteDownload(entry.key);
        }
      }
      _downloads = valid;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> syncCatalog() async {
    if (_isSyncing) {
      return 0;
    }
    _isSyncing = true;
    _error = null;
    notifyListeners();
    try {
      final ExerciseCatalogSnapshot snapshot = await _catalogClient.fetch();
      for (final Exercise exercise in snapshot.exercises) {
        await _exerciseRepository.save(exercise);
      }
      await _mediaRepository.saveAllMedia(snapshot.media);
      _media = await _mediaRepository.getAllMedia();
      _lastSyncedAt = snapshot.generatedAt;
      return snapshot.exercises.length;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> download(ExerciseMedia item) async {
    if (!_downloader.isSupported) {
      throw UnsupportedError('دانلود آفلاین در این محیط پشتیبانی نمی‌شود.');
    }
    if (!item.hasVideo || _downloading.contains(item.exerciseId)) {
      return;
    }

    final ExerciseMediaDownload? oldDownload = _downloads[item.exerciseId];
    _downloading.add(item.exerciseId);
    _progress[item.exerciseId] = 0;
    _error = null;
    notifyListeners();
    try {
      final DownloadedExerciseMedia file = await _downloader.download(
        item,
        onProgress: (int receivedBytes, int? totalBytes) {
          _progress[item.exerciseId] = totalBytes == null || totalBytes <= 0
              ? null
              : (receivedBytes / totalBytes).clamp(0, 1).toDouble();
          notifyListeners();
        },
      );
      final DateTime now = DateTime.now().toUtc();
      final ExerciseMediaDownload download = ExerciseMediaDownload(
        exerciseId: item.exerciseId,
        remoteUrl: item.videoUrl,
        localPath: file.localPath,
        mediaVersion: item.version,
        fileSizeBytes: file.fileSizeBytes,
        downloadedAt: now,
        updatedAt: now,
      );
      await _mediaRepository.saveDownload(download);
      _downloads[item.exerciseId] = download;
      if (oldDownload != null && oldDownload.localPath != file.localPath) {
        await _downloader.delete(oldDownload.localPath);
      }
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _downloading.remove(item.exerciseId);
      _progress.remove(item.exerciseId);
      notifyListeners();
    }
  }

  Future<void> deleteDownload(String exerciseId) async {
    final ExerciseMediaDownload? download = _downloads[exerciseId];
    if (download == null) {
      return;
    }
    await _downloader.delete(download.localPath);
    await _mediaRepository.deleteDownload(exerciseId);
    _downloads.remove(exerciseId);
    notifyListeners();
  }

  @override
  void dispose() {
    _catalogClient.close();
    super.dispose();
  }
}
