enum ExerciseMediaDownloadState {
  notDownloaded,
  downloading,
  downloaded,
  failed;

  String get label => switch (this) {
    ExerciseMediaDownloadState.notDownloaded => 'دانلود نشده',
    ExerciseMediaDownloadState.downloading => 'در حال دانلود',
    ExerciseMediaDownloadState.downloaded => 'دانلود شده',
    ExerciseMediaDownloadState.failed => 'ناموفق',
  };
}

class ExerciseMedia {
  const ExerciseMedia({
    required this.exerciseId,
    required this.videoUrl,
    required this.posterUrl,
    required this.secondaryImageUrl,
    required this.videoSizeBytes,
    required this.durationSeconds,
    required this.version,
    required this.updatedAt,
  });

  final String exerciseId;
  final String videoUrl;
  final String posterUrl;
  final String secondaryImageUrl;
  final int? videoSizeBytes;
  final int? durationSeconds;
  final int version;
  final DateTime updatedAt;

  bool get hasVideo => videoUrl.trim().isNotEmpty;
  bool get hasPoster => posterUrl.trim().isNotEmpty;
  bool get hasSecondaryImage => secondaryImageUrl.trim().isNotEmpty;

  Map<String, Object?> toMap() => <String, Object?>{
    'exercise_id': exerciseId,
    'video_url': videoUrl,
    'poster_url': posterUrl,
    'secondary_image_url': secondaryImageUrl,
    'video_size_bytes': videoSizeBytes,
    'duration_seconds': durationSeconds,
    'media_version': version,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory ExerciseMedia.fromMap(Map<String, Object?> map) {
    return ExerciseMedia(
      exerciseId: map['exercise_id']! as String,
      videoUrl: map['video_url']?.toString() ?? '',
      posterUrl: map['poster_url']?.toString() ?? '',
      secondaryImageUrl: map['secondary_image_url']?.toString() ?? '',
      videoSizeBytes: _nullableInt(map['video_size_bytes']),
      durationSeconds: _nullableInt(map['duration_seconds']),
      version: _nullableInt(map['media_version']) ?? 1,
      updatedAt: DateTime.parse(map['updated_at']! as String).toUtc(),
    );
  }

  factory ExerciseMedia.fromManifest(Map<String, Object?> map) {
    final String exerciseId = map['exerciseId']?.toString().trim() ?? '';
    if (exerciseId.isEmpty) {
      throw const FormatException('شناسه حرکت در رسانه خالی است.');
    }
    final Uri? videoUri = Uri.tryParse(map['videoUrl']?.toString() ?? '');
    if (videoUri == null || !videoUri.hasScheme) {
      throw FormatException('آدرس ویدئوی حرکت $exerciseId معتبر نیست.');
    }
    return ExerciseMedia(
      exerciseId: exerciseId,
      videoUrl: videoUri.toString(),
      posterUrl: _optionalAbsoluteUrl(map['posterUrl'], exerciseId),
      secondaryImageUrl: _optionalAbsoluteUrl(
        map['secondaryImageUrl'],
        exerciseId,
      ),
      videoSizeBytes: _nullableInt(map['videoSizeBytes']),
      durationSeconds: _nullableInt(map['durationSeconds']),
      version: _nullableInt(map['version']) ?? 1,
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }
}

class ExerciseMediaDownload {
  const ExerciseMediaDownload({
    required this.exerciseId,
    required this.remoteUrl,
    required this.localPath,
    required this.mediaVersion,
    required this.fileSizeBytes,
    required this.downloadedAt,
    required this.updatedAt,
  });

  final String exerciseId;
  final String remoteUrl;
  final String localPath;
  final int mediaVersion;
  final int? fileSizeBytes;
  final DateTime downloadedAt;
  final DateTime updatedAt;

  bool matches(ExerciseMedia media) =>
      media.hasVideo &&
      remoteUrl == media.videoUrl &&
      mediaVersion == media.version &&
      localPath.isNotEmpty;

  Map<String, Object?> toMap() => <String, Object?>{
    'exercise_id': exerciseId,
    'remote_url': remoteUrl,
    'local_path': localPath,
    'media_version': mediaVersion,
    'file_size_bytes': fileSizeBytes,
    'downloaded_at': downloadedAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory ExerciseMediaDownload.fromMap(Map<String, Object?> map) {
    return ExerciseMediaDownload(
      exerciseId: map['exercise_id']! as String,
      remoteUrl: map['remote_url']! as String,
      localPath: map['local_path']! as String,
      mediaVersion: _nullableInt(map['media_version']) ?? 1,
      fileSizeBytes: _nullableInt(map['file_size_bytes']),
      downloadedAt: DateTime.parse(map['downloaded_at']! as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at']! as String).toUtc(),
    );
  }
}

int? _nullableInt(Object? raw) {
  if (raw == null) {
    return null;
  }
  if (raw is int) {
    return raw;
  }
  return int.tryParse(raw.toString());
}

String _optionalAbsoluteUrl(Object? raw, String exerciseId) {
  final String value = raw?.toString().trim() ?? '';
  if (value.isEmpty) {
    return '';
  }
  final Uri? uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme) {
    throw FormatException('آدرس تصویر حرکت $exerciseId معتبر نیست.');
  }
  return uri.toString();
}
