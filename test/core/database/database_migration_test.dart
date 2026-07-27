import 'package:coach_app/core/database/database_schema.dart';
import 'package:coach_app/features/athletes/domain/athlete.dart';
import 'package:coach_app/features/exercises/domain/exercise.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('athlete row survives schema migration from v1 to v2', () async {
    final Database database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await database.execute('''
CREATE TABLE ${DatabaseSchema.athletes} (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL DEFAULT '',
  goal TEXT NOT NULL DEFAULT '',
  training_level TEXT NOT NULL DEFAULT 'beginner',
  injuries TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
    await database.execute(DatabaseSchema.athletesActiveIndex);

    const String createdAt = '2026-01-10T08:30:00.000Z';
    await database.insert(DatabaseSchema.athletes, <String, Object?>{
      'id': 'ath-legacy-1',
      'full_name': 'شاگرد نسخه یک',
      'phone': '09120000000',
      'goal': 'افزایش آمادگی عمومی',
      'training_level': 'intermediate',
      'injuries': 'محدودیت قدیمی',
      'notes': 'یادداشت قدیمی مربی',
      'is_active': 1,
      'created_at': createdAt,
      'updated_at': createdAt,
    });

    await database.transaction((Transaction transaction) async {
      for (final String statement in DatabaseSchema.migrateAthletesToV2) {
        await transaction.execute(statement);
      }
    });

    final List<Map<String, Object?>> rows = await database.query(
      DatabaseSchema.athletes,
      where: 'id = ?',
      whereArgs: <Object?>['ath-legacy-1'],
    );

    expect(rows, hasLength(1));
    final Athlete athlete = Athlete.fromMap(rows.single);
    expect(athlete.id, 'ath-legacy-1');
    expect(athlete.fullName, 'شاگرد نسخه یک');
    expect(athlete.phone, '09120000000');
    expect(athlete.goal, 'افزایش آمادگی عمومی');
    expect(athlete.trainingLevel, TrainingLevel.intermediate);
    expect(athlete.injuries, 'محدودیت قدیمی');
    expect(athlete.notes, 'یادداشت قدیمی مربی');
    expect(athlete.primaryGoal, AthleteGoal.generalFitness);
    expect(athlete.experienceMonths, 0);
    expect(athlete.preferredDaysPerWeek, 3);
    expect(athlete.preferredSessionMinutes, 60);
    expect(athlete.trainingEnvironment, TrainingEnvironment.gym);
    expect(athlete.birthDate, isNull);
    expect(athlete.medicalNotes, isEmpty);
    expect(athlete.archivedAt, isNull);
    expect(athlete.createdAt, DateTime.parse(createdAt).toUtc());

    final List<Map<String, Object?>> columns = await database.rawQuery(
      'PRAGMA table_info(${DatabaseSchema.athletes})',
    );
    final Set<String> columnNames = columns
        .map((Map<String, Object?> item) => item['name']! as String)
        .toSet();
    expect(
      columnNames,
      containsAll(<String>{
        'birth_date',
        'primary_goal',
        'experience_months',
        'preferred_days_per_week',
        'preferred_session_minutes',
        'training_environment',
        'medical_notes',
        'archived_at',
      }),
    );

    final List<Map<String, Object?>> indexes = await database.rawQuery(
      'PRAGMA index_list(${DatabaseSchema.athletes})',
    );
    final Set<String> indexNames = indexes
        .map((Map<String, Object?> item) => item['name']! as String)
        .toSet();
    expect(indexNames, contains('idx_athletes_active_name'));
    expect(indexNames, contains('idx_athletes_status_updated'));
    expect(indexNames, contains('idx_athletes_phone'));
  });

  test('v3 migration preserves athletes and seeds exercise catalog', () async {
    final Database database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await database.execute(DatabaseSchema.createAthletes);
    await database.execute(DatabaseSchema.athletesActiveIndex);
    await database.execute(DatabaseSchema.athletesStatusUpdatedIndex);
    await database.execute(DatabaseSchema.athletesPhoneIndex);
    const String timestamp = '2026-07-27T08:00:00.000Z';
    await database.insert(DatabaseSchema.athletes, <String, Object?>{
      'id': 'ath-v2-1',
      'full_name': 'شاگرد نسخه دو',
      'phone': '',
      'birth_date': null,
      'primary_goal': 'generalFitness',
      'goal': '',
      'training_level': 'beginner',
      'experience_months': 0,
      'preferred_days_per_week': 3,
      'preferred_session_minutes': 60,
      'training_environment': 'gym',
      'injuries': '',
      'medical_notes': '',
      'notes': '',
      'is_active': 1,
      'archived_at': null,
      'created_at': timestamp,
      'updated_at': timestamp,
    });

    await database.transaction((Transaction transaction) async {
      for (final String statement in DatabaseSchema.migrateToV3) {
        await transaction.execute(statement);
      }
      for (final Map<String, Object?> seed
          in DatabaseSchema.systemExerciseSeeds) {
        await transaction.insert(DatabaseSchema.exercises, seed);
      }
    });

    final List<Map<String, Object?>> athleteRows = await database.query(
      DatabaseSchema.athletes,
      where: 'id = ?',
      whereArgs: <Object?>['ath-v2-1'],
    );
    expect(athleteRows, hasLength(1));
    expect(Athlete.fromMap(athleteRows.single).fullName, 'شاگرد نسخه دو');

    final List<Map<String, Object?>> exerciseRows = await database.query(
      DatabaseSchema.exercises,
      orderBy: 'name_fa ASC',
    );
    expect(exerciseRows.length, DatabaseSchema.systemExerciseSeeds.length);
    final Exercise exercise = Exercise.fromMap(exerciseRows.first);
    expect(exercise.isSystem, isTrue);
    expect(exercise.isActive, isTrue);
    expect(exercise.nameFa, isNotEmpty);

    final List<Map<String, Object?>> indexes = await database.rawQuery(
      'PRAGMA index_list(${DatabaseSchema.exercises})',
    );
    final Set<String> indexNames = indexes
        .map((Map<String, Object?> item) => item['name']! as String)
        .toSet();
    expect(indexNames, contains('idx_exercises_filters'));
    expect(indexNames, contains('idx_exercises_name'));
    expect(indexNames, contains('idx_exercises_system_active'));
  });

  test('v2 migration is atomic when a statement fails', () async {
    final Database database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    await database.execute('''
CREATE TABLE ${DatabaseSchema.athletes} (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL DEFAULT '',
  goal TEXT NOT NULL DEFAULT '',
  training_level TEXT NOT NULL DEFAULT 'beginner',
  injuries TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');

    await expectLater(
      database.transaction((Transaction transaction) async {
        await transaction.execute(
          'ALTER TABLE ${DatabaseSchema.athletes} ADD COLUMN temporary_value TEXT',
        );
        await transaction.execute('THIS IS INVALID SQL');
      }),
      throwsA(isA<DatabaseException>()),
    );

    final List<Map<String, Object?>> columns = await database.rawQuery(
      'PRAGMA table_info(${DatabaseSchema.athletes})',
    );
    final Set<String> columnNames = columns
        .map((Map<String, Object?> item) => item['name']! as String)
        .toSet();
    expect(columnNames, isNot(contains('temporary_value')));
  });
}
