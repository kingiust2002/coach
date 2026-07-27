import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_schema.dart';
import '../domain/exercise.dart';
import 'exercise_repository.dart';

class SqliteExerciseRepository implements ExerciseRepository {
  const SqliteExerciseRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Exercise>> getAll({bool includeArchived = false}) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      DatabaseSchema.exercises,
      where: includeArchived ? null : 'is_active = ?',
      whereArgs: includeArchived ? null : <Object?>[1],
      orderBy:
          'is_active DESC, is_system DESC, primary_muscle ASC, name_fa COLLATE NOCASE ASC',
    );
    return rows.map(Exercise.fromMap).toList(growable: false);
  }

  @override
  Future<Exercise?> getById(String id) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      DatabaseSchema.exercises,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    return rows.isEmpty ? null : Exercise.fromMap(rows.first);
  }

  @override
  Future<Exercise?> getByNameKey(String nameKey) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      DatabaseSchema.exercises,
      where: 'name_key = ?',
      whereArgs: <Object?>[nameKey],
      limit: 1,
    );
    return rows.isEmpty ? null : Exercise.fromMap(rows.first);
  }

  @override
  Future<void> save(Exercise exercise) async {
    await _database.transaction((Transaction txn) async {
      final int updated = await txn.update(
        DatabaseSchema.exercises,
        exercise.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[exercise.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      if (updated == 0) {
        await txn.insert(
          DatabaseSchema.exercises,
          exercise.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
    });
  }

  @override
  Future<void> archive(String id, DateTime updatedAt) async {
    await _setActive(id, isActive: false, updatedAt: updatedAt);
  }

  @override
  Future<void> restore(String id, DateTime updatedAt) async {
    await _setActive(id, isActive: true, updatedAt: updatedAt);
  }

  Future<void> _setActive(
    String id, {
    required bool isActive,
    required DateTime updatedAt,
  }) async {
    final Database db = await _database.open();
    final String timestamp = updatedAt.toUtc().toIso8601String();
    final int changed = await db.update(
      DatabaseSchema.exercises,
      <String, Object?>{
        'is_active': isActive ? 1 : 0,
        'archived_at': isActive ? null : timestamp,
        'updated_at': timestamp,
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    if (changed != 1) {
      throw StateError('Exercise $id was not found.');
    }
  }
}
