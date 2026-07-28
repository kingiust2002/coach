import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/exercise_media.dart';
import 'exercise_media_repository.dart';
import 'exercise_media_schema.dart';

class SqliteExerciseMediaRepository implements ExerciseMediaRepository {
  const SqliteExerciseMediaRepository(this._database);

  final AppDatabase _database;

  @override
  Future<ExerciseMedia?> getMedia(String exerciseId) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      ExerciseMediaSchema.mediaTable,
      where: 'exercise_id = ?',
      whereArgs: <Object?>[exerciseId],
      limit: 1,
    );
    return rows.isEmpty ? null : ExerciseMedia.fromMap(rows.single);
  }

  @override
  Future<Map<String, ExerciseMedia>> getAllMedia() async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      ExerciseMediaSchema.mediaTable,
      orderBy: 'updated_at DESC',
    );
    return <String, ExerciseMedia>{
      for (final Map<String, Object?> row in rows)
        row['exercise_id']! as String: ExerciseMedia.fromMap(row),
    };
  }

  @override
  Future<void> saveMedia(ExerciseMedia media) async {
    final Database db = await _database.open();
    await db.insert(
      ExerciseMediaSchema.mediaTable,
      media.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveAllMedia(Iterable<ExerciseMedia> media) async {
    await _database.transaction((Transaction txn) async {
      for (final ExerciseMedia item in media) {
        await txn.insert(
          ExerciseMediaSchema.mediaTable,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<ExerciseMediaDownload?> getDownload(String exerciseId) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      ExerciseMediaSchema.downloadsTable,
      where: 'exercise_id = ?',
      whereArgs: <Object?>[exerciseId],
      limit: 1,
    );
    return rows.isEmpty ? null : ExerciseMediaDownload.fromMap(rows.single);
  }

  @override
  Future<Map<String, ExerciseMediaDownload>> getAllDownloads() async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.query(
      ExerciseMediaSchema.downloadsTable,
      orderBy: 'updated_at DESC',
    );
    return <String, ExerciseMediaDownload>{
      for (final Map<String, Object?> row in rows)
        row['exercise_id']! as String: ExerciseMediaDownload.fromMap(row),
    };
  }

  @override
  Future<void> saveDownload(ExerciseMediaDownload download) async {
    final Database db = await _database.open();
    await db.insert(
      ExerciseMediaSchema.downloadsTable,
      download.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteDownload(String exerciseId) async {
    final Database db = await _database.open();
    await db.delete(
      ExerciseMediaSchema.downloadsTable,
      where: 'exercise_id = ?',
      whereArgs: <Object?>[exerciseId],
    );
  }
}
