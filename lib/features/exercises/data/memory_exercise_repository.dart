import '../../../core/database/database_schema.dart';
import '../domain/exercise.dart';
import 'exercise_repository.dart';

/// Volatile repository used by browser previews where SQLite is unavailable.
/// System exercises are seeded on each page load and custom changes are reset
/// when the browser page reloads.
class MemoryExerciseRepository implements ExerciseRepository {
  MemoryExerciseRepository()
    : _items = <String, Exercise>{
        for (final Map<String, Object?> seed
            in DatabaseSchema.systemExerciseSeeds)
          seed['id']! as String: Exercise.fromMap(seed),
      };

  final Map<String, Exercise> _items;

  @override
  Future<List<Exercise>> getAll({bool includeArchived = false}) async {
    final List<Exercise> result = _items.values
        .where((Exercise item) => includeArchived || item.isActive)
        .toList();
    result.sort((Exercise a, Exercise b) {
      final int activeOrder = (b.isActive ? 1 : 0).compareTo(
        a.isActive ? 1 : 0,
      );
      if (activeOrder != 0) {
        return activeOrder;
      }
      final int systemOrder = (b.isSystem ? 1 : 0).compareTo(
        a.isSystem ? 1 : 0,
      );
      if (systemOrder != 0) {
        return systemOrder;
      }
      final int muscleOrder = a.primaryMuscle.name.compareTo(
        b.primaryMuscle.name,
      );
      if (muscleOrder != 0) {
        return muscleOrder;
      }
      return a.nameFa.compareTo(b.nameFa);
    });
    return List<Exercise>.unmodifiable(result);
  }

  @override
  Future<Exercise?> getById(String id) async => _items[id];

  @override
  Future<Exercise?> getByNameKey(String nameKey) async {
    for (final Exercise exercise in _items.values) {
      if (exercise.nameKey == nameKey) {
        return exercise;
      }
    }
    return null;
  }

  @override
  Future<void> save(Exercise exercise) async {
    final Exercise? duplicate = await getByNameKey(exercise.nameKey);
    if (duplicate != null && duplicate.id != exercise.id) {
      throw StateError('حرکتی با این نام از قبل وجود دارد.');
    }
    _items[exercise.id] = exercise;
  }

  @override
  Future<void> archive(String id, DateTime updatedAt) async {
    _setActive(id, isActive: false, updatedAt: updatedAt);
  }

  @override
  Future<void> restore(String id, DateTime updatedAt) async {
    _setActive(id, isActive: true, updatedAt: updatedAt);
  }

  void _setActive(
    String id, {
    required bool isActive,
    required DateTime updatedAt,
  }) {
    final Exercise? exercise = _items[id];
    if (exercise == null) {
      throw StateError('Exercise $id was not found.');
    }
    final DateTime timestamp = updatedAt.toUtc();
    _items[id] = Exercise(
      id: exercise.id,
      nameFa: exercise.nameFa,
      nameKey: exercise.nameKey,
      nameEn: exercise.nameEn,
      primaryMuscle: exercise.primaryMuscle,
      secondaryMuscles: exercise.secondaryMuscles,
      type: exercise.type,
      equipment: exercise.equipment,
      difficulty: exercise.difficulty,
      movementPattern: exercise.movementPattern,
      laterality: exercise.laterality,
      instructions: exercise.instructions,
      safetyNotes: exercise.safetyNotes,
      coachNotes: exercise.coachNotes,
      isActive: isActive,
      isSystem: exercise.isSystem,
      archivedAt: isActive ? null : timestamp,
      createdAt: exercise.createdAt,
      updatedAt: timestamp,
    );
  }
}
