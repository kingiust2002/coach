import '../domain/exercise_media.dart';

abstract interface class ExerciseMediaRepository {
  Future<ExerciseMedia?> getMedia(String exerciseId);

  Future<Map<String, ExerciseMedia>> getAllMedia();

  Future<void> saveMedia(ExerciseMedia media);

  Future<void> saveAllMedia(Iterable<ExerciseMedia> media);

  Future<ExerciseMediaDownload?> getDownload(String exerciseId);

  Future<Map<String, ExerciseMediaDownload>> getAllDownloads();

  Future<void> saveDownload(ExerciseMediaDownload download);

  Future<void> deleteDownload(String exerciseId);
}
