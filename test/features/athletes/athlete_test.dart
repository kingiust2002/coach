import 'package:coach_app/features/athletes/domain/athlete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Athlete survives database map round trip', () {
    final DateTime createdAt = DateTime.utc(2026, 7, 26, 12);
    final Athlete source = Athlete(
      id: 'ath-1',
      fullName: 'آزمون مربی',
      phone: '09120000000',
      birthDate: DateTime.utc(1998, 4, 12),
      primaryGoal: AthleteGoal.strength,
      goal: 'افزایش قدرت اسکوات و ددلیفت',
      trainingLevel: TrainingLevel.intermediate,
      experienceMonths: 24,
      preferredDaysPerWeek: 4,
      preferredSessionMinutes: 75,
      trainingEnvironment: TrainingEnvironment.gym,
      injuries: 'حساسیت خفیف زانو',
      medicalNotes: 'طبق اعلام شاگرد منع پزشکی ندارد',
      notes: 'کنترل فرم اسکوات',
      isActive: true,
      archivedAt: null,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final Athlete restored = Athlete.fromMap(source.toMap());

    expect(restored.id, source.id);
    expect(restored.fullName, source.fullName);
    expect(restored.birthDate, source.birthDate);
    expect(restored.primaryGoal, AthleteGoal.strength);
    expect(restored.trainingLevel, source.trainingLevel);
    expect(restored.experienceMonths, 24);
    expect(restored.preferredDaysPerWeek, 4);
    expect(restored.preferredSessionMinutes, 75);
    expect(restored.trainingEnvironment, TrainingEnvironment.gym);
    expect(restored.createdAt, createdAt);
    expect(restored.isActive, isTrue);
  });

  test('Athlete reads safe defaults from a legacy row', () {
    final Athlete restored = Athlete.fromMap(<String, Object?>{
      'id': 'ath-legacy',
      'full_name': 'شاگرد قدیمی',
      'phone': '',
      'goal': 'سلامت عمومی',
      'training_level': 'beginner',
      'injuries': '',
      'notes': '',
      'is_active': 1,
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-01-01T00:00:00.000Z',
    });

    expect(restored.primaryGoal, AthleteGoal.generalFitness);
    expect(restored.experienceMonths, 0);
    expect(restored.preferredDaysPerWeek, 3);
    expect(restored.preferredSessionMinutes, 60);
    expect(restored.trainingEnvironment, TrainingEnvironment.gym);
    expect(restored.birthDate, isNull);
    expect(restored.archivedAt, isNull);
  });

  test('ageAt accounts for whether birthday has passed', () {
    final Athlete athlete = Athlete(
      id: 'ath-age',
      fullName: 'سن آزمایشی',
      phone: '',
      birthDate: DateTime.utc(2000, 10, 20),
      primaryGoal: AthleteGoal.generalFitness,
      goal: '',
      trainingLevel: TrainingLevel.beginner,
      experienceMonths: 0,
      preferredDaysPerWeek: 3,
      preferredSessionMinutes: 60,
      trainingEnvironment: TrainingEnvironment.gym,
      injuries: '',
      medicalNotes: '',
      notes: '',
      isActive: true,
      archivedAt: null,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    expect(athlete.ageAt(DateTime.utc(2026, 10, 19)), 25);
    expect(athlete.ageAt(DateTime.utc(2026, 10, 20)), 26);
  });
}
