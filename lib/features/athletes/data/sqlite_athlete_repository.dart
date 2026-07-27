import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_schema.dart';
import '../domain/athlete.dart';
import 'athlete_repository.dart';

class SqliteAthleteRepository implements AthleteRepository {
  const SqliteAthleteRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Athlete>> getAll({bool includeArchived = false}) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      DatabaseSchema.athletes,
      where: includeArchived ? null : 'is_active = ?',
      whereArgs: includeArchived ? null : <Object?>[1],
      orderBy: 'is_active DESC, updated_at DESC, full_name COLLATE NOCASE ASC',
    );

    return rows.map(Athlete.fromMap).toList(growable: false);
  }

  @override
  Future<Athlete?> getById(String id) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      DatabaseSchema.athletes,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );

    return rows.isEmpty ? null : Athlete.fromMap(rows.first);
  }

  @override
  Future<void> save(Athlete athlete) async {
    await _database.transaction((Transaction txn) async {
      final int updated = await txn.update(
        DatabaseSchema.athletes,
        athlete.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[athlete.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      if (updated == 0) {
        await txn.insert(
          DatabaseSchema.athletes,
          athlete.toMap(),
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
      DatabaseSchema.athletes,
      <String, Object?>{
        'is_active': isActive ? 1 : 0,
        'archived_at': isActive ? null : timestamp,
        'updated_at': timestamp,
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    if (changed != 1) {
      throw StateError('Athlete $id was not found.');
    }
  }
}
