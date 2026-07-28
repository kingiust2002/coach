import '../domain/exercise_media.dart';

typedef ExerciseDownloadProgress = void Function(int receivedBytes, int? totalBytes);

class DownloadedExerciseMedia {
  const DownloadedExerciseMedia({
    required this.localPath,
    required this.fileSizeBytes,
  });

  final String localPath;
  final int fileSizeBytes;
}

abstract interface class ExerciseMediaDownloader {
  bool get isSupported;

  Future<DownloadedExerciseMedia> download(
    ExerciseMedia media, {
    required ExerciseDownloadProgress onProgress,
  });

  Future<bool> exists(String localPath);

  Future<void> delete(String localPath);
}
