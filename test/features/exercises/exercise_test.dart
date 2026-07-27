import 'package:coach_app/features/exercises/domain/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exercise map round trip preserves catalog fields', () {
    final DateTime createdAt = DateTime.utc(2026, 7, 27, 10);
    final Exercise exercise = Exercise(
      id: 'ex-test-1',
      nameFa: 'پرس سینه دمبل',
      nameKey: 'پرس سینه دمبل',
      nameEn: 'Dumbbell Bench Press',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: <MuscleGroup>{
        MuscleGroup.triceps,
        MuscleGroup.shoulders,
      },
      type: ExerciseType.compound,
      equipment: ExerciseEquipment.dumbbell,
      difficulty: ExerciseDifficulty.beginner,
      movementPattern: MovementPattern.horizontalPush,
      laterality: ExerciseLaterality.bilateral,
      instructions: 'حرکت کنترل‌شده اجرا شود.',
      safetyNotes: 'کتف‌ها پایدار بمانند.',
      coachNotes: 'برای شاگرد تازه‌کار سبک شروع شود.',
      isActive: true,
      isSystem: false,
      archivedAt: null,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final Exercise decoded = Exercise.fromMap(exercise.toMap());

    expect(decoded.id, exercise.id);
    expect(decoded.nameFa, exercise.nameFa);
    expect(decoded.nameEn, exercise.nameEn);
    expect(decoded.primaryMuscle, MuscleGroup.chest);
    expect(decoded.secondaryMuscles, exercise.secondaryMuscles);
    expect(decoded.type, ExerciseType.compound);
    expect(decoded.equipment, ExerciseEquipment.dumbbell);
    expect(decoded.difficulty, ExerciseDifficulty.beginner);
    expect(decoded.movementPattern, MovementPattern.horizontalPush);
    expect(decoded.laterality, ExerciseLaterality.bilateral);
    expect(decoded.isSystem, isFalse);
    expect(decoded.createdAt, createdAt);
  });
}
