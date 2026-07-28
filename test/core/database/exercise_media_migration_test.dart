import 'package:coach_app/core/database/database_schema.dart';
import 'package:coach_app/features/exercises/data/exercise_media_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('v4 media migration preserves existing exercise rows', () async {
    final Database database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);

    for (final String statement in DatabaseSchema.migrateToV3) {
      await database.execute(statement);
    }
    final Map<String, Object?> seed = DatabaseSchema.systemExerciseSeeds.first;
    await database.insert(DatabaseSchema.exercises, seed);

    await database.transaction((Transaction transaction) async {
      for (final String statement in ExerciseMediaSchema.migrateToV4) {
        await transaction.execute(statement);
      }
    });

    final List<Map<String, Object?>> exercises = await database.query(
      DatabaseSchema.exercises,
      where: 'id = ?',
      whereArgs: <Object?>[seed['id']],
    );
    expect(exercises, hasLength(1));

    final List<Map<String, Object?>> tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final Set<String> names = tables
        .map((Map<String, Object?> row) => row['name']! as String)
        .toSet();
    expect(names, contains(ExerciseMediaSchema.mediaTable));
    expect(names, contains(ExerciseMediaSchema.downloadsTable));
  });
}
