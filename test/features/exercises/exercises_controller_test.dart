import 'package:coach_app/features/exercises/data/exercise_repository.dart';
import 'package:coach_app/features/exercises/domain/exercise.dart';
import 'package:coach_app/features/exercises/presentation/exercises_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryExerciseRepository implements ExerciseRepository {
  final Map<String, Exercise> _items = <String, Exercise>{};

  @override
  Future<void> archive(String id, DateTime updatedAt) async {
    final Exercise current = _items[id]!;
    _items[id] = Exercise.fromMap(<String, Object?>{
      ...current.toMap(),
      'is_active': 0,
      'archived_at': updatedAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<Exercise>> getAll({bool includeArchived = false}) async {
    return _items.values
        .where((Exercise item) => includeArchived || item.isActive)
        .toList(growable: false);
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
  Future<void> restore(String id, DateTime updatedAt) async {
    final Exercise current = _items[id]!;
    _items[id] = Exercise.fromMap(<String, Object?>{
      ...current.toMap(),
      'is_active': 1,
      'archived_at': null,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> save(Exercise exercise) async {
    _items[exercise.id] = exercise;
  }
}

ExerciseInput _input({String name = 'پرس آرنولدی'}) => ExerciseInput(
      nameFa: name,
      nameEn: 'Arnold Press',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: <MuscleGroup>{MuscleGroup.triceps},
      type: ExerciseType.compound,
      equipment: ExerciseEquipment.dumbbell,
      difficulty: ExerciseDifficulty.intermediate,
      movementPattern: MovementPattern.verticalPush,
      laterality: ExerciseLaterality.bilateral,
      instructions: 'با کنترل اجرا شود.',
      safetyNotes: 'دامنه بدون درد باشد.',
      coachNotes: '',
    );

void main() {
  test('create archive and restore keep the same exercise id', () async {
    final _MemoryExerciseRepository repository = _MemoryExerciseRepository();
    final ExercisesController controller = ExercisesController(repository);

    await controller.create(_input());
    expect(controller.exercises, hasLength(1));
    final Exercise created = controller.exercises.single;
    expect(created.isActive, isTrue);
    expect(created.isSystem, isFalse);

    await controller.archive(created);
    final Exercise archived = controller.byId(created.id)!;
    expect(archived.id, created.id);
    expect(archived.isActive, isFalse);
    expect(archived.archivedAt, isNotNull);

    await controller.restore(archived);
    final Exercise restored = controller.byId(created.id)!;
    expect(restored.id, created.id);
    expect(restored.isActive, isTrue);
    expect(restored.archivedAt, isNull);
  });

  test('duplicate Persian name is rejected after normalization', () async {
    final _MemoryExerciseRepository repository = _MemoryExerciseRepository();
    final ExercisesController controller = ExercisesController(repository);

    await controller.create(_input(name: 'پرس آرنولدی'));

    await expectLater(
      controller.create(_input(name: '  پرس   آرنولدی  ')),
      throwsA(isA<FormatException>()),
    );
    expect(controller.exercises, hasLength(1));
  });

  test('primary muscle is removed from secondary muscles', () async {
    final _MemoryExerciseRepository repository = _MemoryExerciseRepository();
    final ExercisesController controller = ExercisesController(repository);

    await controller.create(
      ExerciseInput(
        nameFa: 'حرکت آزمایشی',
        nameEn: '',
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: <MuscleGroup>{
          MuscleGroup.chest,
          MuscleGroup.triceps,
        },
        type: ExerciseType.compound,
        equipment: ExerciseEquipment.bodyweight,
        difficulty: ExerciseDifficulty.beginner,
        movementPattern: MovementPattern.horizontalPush,
        laterality: ExerciseLaterality.bilateral,
        instructions: '',
        safetyNotes: '',
        coachNotes: '',
      ),
    );

    expect(
      controller.exercises.single.secondaryMuscles,
      <MuscleGroup>{MuscleGroup.triceps},
    );
  });
}
