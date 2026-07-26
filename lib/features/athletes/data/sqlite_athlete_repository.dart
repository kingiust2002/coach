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
      orderBy: 'updated_at DESC, full_name COLLATE NOCASE ASC',
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
    final Database db = await _database.open();
    await db.insert(
      DatabaseSchema.athletes,
      athlete.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> archive(String id, DateTime updatedAt) async {
    final Database db = await _database.open();
    await db.update(
      DatabaseSchema.athletes,
      <String, Object?>{
        'is_active': 0,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
