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
    await _database.transaction((Transaction txn) async {
      await _upsert(
        txn,
        table: ExerciseMediaSchema.mediaTable,
        id: media.exerciseId,
        values: media.toMap(),
      );
    });
  }

  @override
  Future<void> saveAllMedia(Iterable<ExerciseMedia> media) async {
    await _database.transaction((Transaction txn) async {
      for (final ExerciseMedia item in media) {
        await _upsert(
          txn,
          table: ExerciseMediaSchema.mediaTable,
          id: item.exerciseId,
          values: item.toMap(),
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
    await _database.transaction((Transaction txn) async {
      await _upsert(
        txn,
        table: ExerciseMediaSchema.downloadsTable,
        id: download.exerciseId,
        values: download.toMap(),
      );
    });
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

  Future<void> _upsert(
    DatabaseExecutor executor, {
    required String table,
    required String id,
    required Map<String, Object?> values,
  }) async {
    final int updated = await executor.update(
      table,
      values,
      where: 'exercise_id = ?',
      whereArgs: <Object?>[id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    if (updated == 0) {
      await executor.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }
}
