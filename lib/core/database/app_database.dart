import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_schema.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> open() async {
    final Database? current = _database;
    if (current != null && current.isOpen) {
      return current;
    }

    final String directory = await getDatabasesPath();
    final String path = p.join(directory, DatabaseSchema.fileName);

    final Database database = await openDatabase(
      path,
      version: DatabaseSchema.version,
      singleInstance: true,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute('PRAGMA busy_timeout = 5000');
      },
      onCreate: (Database db, int version) async {
        await db.transaction((Transaction txn) async {
          await _createAthletes(txn);
          await _createExercises(txn);
        });
      },
      onUpgrade: _upgrade,
      onDowngrade: (Database db, int oldVersion, int newVersion) async {
        throw StateError(
          'Database downgrade from $oldVersion to $newVersion is not supported.',
        );
      },
    );

    _database = database;
    return database;
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    for (
      int targetVersion = oldVersion + 1;
      targetVersion <= newVersion;
      targetVersion++
    ) {
      await _migrateTo(db, targetVersion);
    }
  }

  Future<void> _migrateTo(Database db, int targetVersion) async {
    switch (targetVersion) {
      case 1:
        await db.transaction(_createAthletes);
        return;
      case 2:
        await db.transaction((Transaction txn) async {
          for (final String statement in DatabaseSchema.migrateAthletesToV2) {
            await txn.execute(statement);
          }
        });
        return;
      case 3:
        await db.transaction(_createExercises);
        return;
      default:
        throw StateError(
          'Migration for database version $targetVersion is missing.',
        );
    }
  }

  static Future<void> _createAthletes(Transaction txn) async {
    await txn.execute(DatabaseSchema.createAthletes);
    await txn.execute(DatabaseSchema.athletesActiveIndex);
    await txn.execute(DatabaseSchema.athletesStatusUpdatedIndex);
    await txn.execute(DatabaseSchema.athletesPhoneIndex);
  }

  static Future<void> _createExercises(Transaction txn) async {
    for (final String statement in DatabaseSchema.migrateToV3) {
      await txn.execute(statement);
    }
    for (final Map<String, Object?> seed
        in DatabaseSchema.systemExerciseSeeds) {
      await txn.insert(
        DatabaseSchema.exercises,
        seed,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final Database database = await open();
    return database.transaction(action);
  }

  Future<void> close() async {
    final Database? current = _database;
    if (current != null && current.isOpen) {
      await current.close();
    }
    _database = null;
  }
}
