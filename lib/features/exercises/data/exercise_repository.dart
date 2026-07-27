import '../domain/exercise.dart';

abstract interface class ExerciseRepository {
  Future<List<Exercise>> getAll({bool includeArchived = false});

  Future<Exercise?> getById(String id);

  Future<Exercise?> getByNameKey(String nameKey);

  Future<void> save(Exercise exercise);

  Future<void> archive(String id, DateTime updatedAt);

  Future<void> restore(String id, DateTime updatedAt);
}
