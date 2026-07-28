import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/exercise.dart';
import '../domain/exercise_media.dart';

class ExerciseCatalogSnapshot {
  const ExerciseCatalogSnapshot({
    required this.schemaVersion,
    required this.generatedAt,
    required this.exercises,
    required this.media,
  });

  final int schemaVersion;
  final DateTime generatedAt;
  final List<Exercise> exercises;
  final List<ExerciseMedia> media;
}

class ExerciseCatalogClient {
  ExerciseCatalogClient({
    String? manifestUrl,
    http.Client? client,
  }) : manifestUrl = manifestUrl ??
            const String.fromEnvironment('EXERCISE_CATALOG_URL'),
       _client = client ?? http.Client();

  final String manifestUrl;
  final http.Client _client;

  bool get isConfigured => Uri.tryParse(manifestUrl)?.hasScheme ?? false;

  Future<ExerciseCatalogSnapshot> fetch() async {
    final Uri? uri = Uri.tryParse(manifestUrl);
    if (uri == null || !uri.hasScheme) {
      throw const StateError(
        'آدرس کتابخانه آنلاین تنظیم نشده است. EXERCISE_CATALOG_URL را مشخص کنید.',
      );
    }

    final http.Response response = await _client
        .get(uri, headers: const <String, String>{'accept': 'application/json'})
        .timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'دریافت کتابخانه با خطای HTTP ${response.statusCode} متوقف شد.',
      );
    }

    final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('ساختار فایل کتابخانه معتبر نیست.');
    }

    final int schemaVersion = _requiredInt(decoded['schemaVersion']);
    if (schemaVersion != 1) {
      throw FormatException(
        'نسخه ساختار کتابخانه $schemaVersion پشتیبانی نمی‌شود.',
      );
    }

    final List<dynamic> rawItems = decoded['items'] is List<dynamic>
        ? decoded['items']! as List<dynamic>
        : <dynamic>[];
    final List<Exercise> exercises = <Exercise>[];
    final List<ExerciseMedia> media = <ExerciseMedia>[];

    for (final dynamic rawItem in rawItems) {
      if (rawItem is! Map<String, dynamic>) {
        throw const FormatException('یکی از حرکات کتابخانه معتبر نیست.');
      }
      final Map<String, Object?> rawExercise = Map<String, Object?>.from(
        rawItem['exercise']! as Map<dynamic, dynamic>,
      );
      final Exercise exercise = Exercise.fromMap(rawExercise);
      if (!exercise.isSystem) {
        throw FormatException(
          'حرکت آنلاین ${exercise.id} باید به‌عنوان حرکت سیستمی ثبت شود.',
        );
      }
      exercises.add(exercise);

      final Object? rawMedia = rawItem['media'];
      if (rawMedia is Map<dynamic, dynamic>) {
        final Map<String, Object?> mediaMap = Map<String, Object?>.from(rawMedia);
        mediaMap['exerciseId'] = exercise.id;
        media.add(ExerciseMedia.fromManifest(mediaMap));
      }
    }

    final DateTime generatedAt =
        DateTime.tryParse(decoded['generatedAt']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc();
    return ExerciseCatalogSnapshot(
      schemaVersion: schemaVersion,
      generatedAt: generatedAt,
      exercises: List<Exercise>.unmodifiable(exercises),
      media: List<ExerciseMedia>.unmodifiable(media),
    );
  }

  void close() => _client.close();
}

int _requiredInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  final int? parsed = int.tryParse(raw?.toString() ?? '');
  if (parsed == null) {
    throw const FormatException('نسخه ساختار کتابخانه مشخص نیست.');
  }
  return parsed;
}
