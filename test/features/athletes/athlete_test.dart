import 'package:coach_app/features/athletes/domain/athlete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Athlete survives database map round trip', () {
    final DateTime createdAt = DateTime.utc(2026, 7, 26, 12);
    final Athlete source = Athlete(
      id: 'ath-1',
      fullName: 'آزمون مربی',
      phone: '09120000000',
      goal: 'افزایش قدرت',
      trainingLevel: TrainingLevel.intermediate,
      injuries: 'ندارد',
      notes: 'کنترل فرم اسکوات',
      isActive: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final Athlete restored = Athlete.fromMap(source.toMap());

    expect(restored.id, source.id);
    expect(restored.fullName, source.fullName);
    expect(restored.trainingLevel, source.trainingLevel);
    expect(restored.createdAt, createdAt);
    expect(restored.isActive, isTrue);
  });
}
