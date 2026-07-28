class ExerciseMedia {
  const ExerciseMedia({
    required this.exerciseId,
    required this.fullVideoUrl,
    this.imageUrls = const <String>[],
    this.version = 1,
    this.sizeBytes,
    this.durationSeconds,
    this.sha256 = '',
    this.updatedAt,
  }) : assert(imageUrls.length <= 2);

  final String exerciseId;
  final String fullVideoUrl;
  final List<String> imageUrls;
  final int version;
  final int? sizeBytes;
  final int? durationSeconds;
  final String sha256;
  final DateTime? updatedAt;

  bool get hasVideo => Uri.tryParse(fullVideoUrl)?.hasScheme ?? false;

  factory ExerciseMedia.fromJson(Map<String, dynamic> json) {
    final Object? rawImages = json['image_urls'];
    final List<String> imageUrls = rawImages is List<dynamic>
        ? rawImages
              .whereType<String>()
              .map((String item) => item.trim())
              .where((String item) => item.isNotEmpty)
              .take(2)
              .toList(growable: false)
        : const <String>[];
    return ExerciseMedia(
      exerciseId: (json['exercise_id'] ?? '').toString().trim(),
      fullVideoUrl: (json['full_video_url'] ?? '').toString().trim(),
      imageUrls: imageUrls,
      version: _positiveInt(json['version']) ?? 1,
      sizeBytes: _positiveInt(json['size_bytes']),
      durationSeconds: _positiveInt(json['duration_seconds']),
      sha256: (json['sha256'] ?? '').toString().trim().toLowerCase(),
      updatedAt: _dateOrNull(json['updated_at']),
    );
  }
}

class ExerciseVideoDownload {
  const ExerciseVideoDownload({
    required this.exerciseId,
    required this.mediaVersion,
    required this.localPath,
    required this.bytes,
    required this.downloadedAt,
  });

  final String exerciseId;
  final int mediaVersion;
  final String localPath;
  final int bytes;
  final DateTime downloadedAt;
}

int? _positiveInt(Object? value) {
  final int? parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
  return parsed != null && parsed >= 0 ? parsed : null;
}

DateTime? _dateOrNull(Object? value) {
  final String raw = value?.toString() ?? '';
  return raw.isEmpty ? null : DateTime.tryParse(raw)?.toUtc();
}
