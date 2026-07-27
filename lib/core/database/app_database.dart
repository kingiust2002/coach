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
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (Database db, int version) async {
        await db.transaction((Transaction txn) async {
          await txn.execute(DatabaseSchema.createAthletes);
          await txn.execute(DatabaseSchema.athletesActiveIndex);
        });
      },
      onUpgrade: _upgrade,
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
        await db.transaction((Transaction txn) async {
          await txn.execute(DatabaseSchema.createAthletes);
          await txn.execute(DatabaseSchema.athletesActiveIndex);
        });
        return;
      default:
        throw StateError(
          'Migration for database version $targetVersion is missing.',
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
