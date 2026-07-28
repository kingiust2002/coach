abstract final class ExerciseMediaSchema {
  static const int databaseVersion = 4;

  static const String mediaTable = 'exercise_media';
  static const String downloadsTable = 'exercise_media_downloads';

  static const String createMediaTable =
      '''
CREATE TABLE $mediaTable (
  exercise_id TEXT PRIMARY KEY,
  video_url TEXT NOT NULL DEFAULT '',
  poster_url TEXT NOT NULL DEFAULT '',
  secondary_image_url TEXT NOT NULL DEFAULT '',
  video_size_bytes INTEGER,
  duration_seconds INTEGER,
  media_version INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
)
''';

  static const String createDownloadsTable =
      '''
CREATE TABLE $downloadsTable (
  exercise_id TEXT PRIMARY KEY,
  remote_url TEXT NOT NULL,
  local_path TEXT NOT NULL,
  media_version INTEGER NOT NULL,
  file_size_bytes INTEGER,
  downloaded_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
)
''';

  static const String mediaUpdatedIndex =
      '''
CREATE INDEX idx_exercise_media_updated
ON $mediaTable (updated_at DESC)
''';

  static const String downloadsUpdatedIndex =
      '''
CREATE INDEX idx_exercise_media_downloads_updated
ON $downloadsTable (updated_at DESC)
''';

  static const List<String> migrateToV4 = <String>[
    createMediaTable,
    createDownloadsTable,
    mediaUpdatedIndex,
    downloadsUpdatedIndex,
  ];
}
