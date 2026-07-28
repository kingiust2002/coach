import '../domain/exercise_media.dart';

abstract interface class ExerciseMediaCatalog {
  Future<List<ExerciseMedia>> load({bool forceRefresh = false});
}

class EmptyExerciseMediaCatalog implements ExerciseMediaCatalog {
  const EmptyExerciseMediaCatalog();

  @override
  Future<List<ExerciseMedia>> load({bool forceRefresh = false}) async {
    return const <ExerciseMedia>[];
  }
}
