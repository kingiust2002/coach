import '../domain/exercise_media.dart';
import 'exercise_media_repository.dart';

class MemoryExerciseMediaRepository implements ExerciseMediaRepository {
  final Map<String, ExerciseMedia> _media = <String, ExerciseMedia>{};
  final Map<String, ExerciseMediaDownload> _downloads =
      <String, ExerciseMediaDownload>{};

  @override
  Future<ExerciseMedia?> getMedia(String exerciseId) async =>
      _media[exerciseId];

  @override
  Future<Map<String, ExerciseMedia>> getAllMedia() async =>
      Map<String, ExerciseMedia>.unmodifiable(_media);

  @override
  Future<void> saveMedia(ExerciseMedia media) async {
    _media[media.exerciseId] = media;
  }

  @override
  Future<void> saveAllMedia(Iterable<ExerciseMedia> media) async {
    for (final ExerciseMedia item in media) {
      _media[item.exerciseId] = item;
    }
  }

  @override
  Future<ExerciseMediaDownload?> getDownload(String exerciseId) async =>
      _downloads[exerciseId];

  @override
  Future<Map<String, ExerciseMediaDownload>> getAllDownloads() async =>
      Map<String, ExerciseMediaDownload>.unmodifiable(_downloads);

  @override
  Future<void> saveDownload(ExerciseMediaDownload download) async {
    _downloads[download.exerciseId] = download;
  }

  @override
  Future<void> deleteDownload(String exerciseId) async {
    _downloads.remove(exerciseId);
  }
}
