import '../domain/exercise_media.dart';

typedef DownloadProgress = void Function(double value);

abstract interface class ExerciseVideoStore {
  bool get canDownload;

  Future<ExerciseVideoDownload?> locate(ExerciseMedia media);

  Future<ExerciseVideoDownload> download(
    ExerciseMedia media, {
    DownloadProgress? onProgress,
  });

  Future<void> delete(ExerciseMedia media);
}

class UnsupportedExerciseVideoStore implements ExerciseVideoStore {
  const UnsupportedExerciseVideoStore();

  @override
  bool get canDownload => false;

  @override
  Future<void> delete(ExerciseMedia media) async {}

  @override
  Future<ExerciseVideoDownload> download(
    ExerciseMedia media, {
    DownloadProgress? onProgress,
  }) {
    throw UnsupportedError('دانلود آفلاین در این محیط پشتیبانی نمی‌شود.');
  }

  @override
  Future<ExerciseVideoDownload?> locate(ExerciseMedia media) async => null;
}
