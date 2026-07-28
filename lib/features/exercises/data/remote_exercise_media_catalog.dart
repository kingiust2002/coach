import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/exercise_media.dart';
import 'exercise_media_catalog.dart';

class RemoteExerciseMediaCatalog implements ExerciseMediaCatalog {
  RemoteExerciseMediaCatalog({
    required this.endpoint,
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  static const String _cacheKey = 'exercise_media_manifest_v1';

  final Uri? endpoint;
  final SharedPreferences _preferences;

  @override
  Future<List<ExerciseMedia>> load({bool forceRefresh = false}) async {
    final Uri? remote = endpoint;
    if (remote != null) {
      try {
        final http.Response response = await http
            .get(remote, headers: const <String, String>{'accept': 'application/json'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final List<ExerciseMedia> parsed = _parse(response.body);
          await _preferences.setString(_cacheKey, response.body);
          return parsed;
        }
        if (forceRefresh) {
          throw StateError('Media catalog returned HTTP ${response.statusCode}.');
        }
      } catch (_) {
        if (forceRefresh && !_preferences.containsKey(_cacheKey)) {
          rethrow;
        }
      }
    }

    final String? cached = _preferences.getString(_cacheKey);
    return cached == null ? const <ExerciseMedia>[] : _parse(cached);
  }

  List<ExerciseMedia> _parse(String source) {
    final dynamic decoded = jsonDecode(source);
    final List<dynamic> rows = switch (decoded) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map when map['items'] is List<dynamic> =>
        map['items'] as List<dynamic>,
      final Map<String, dynamic> map when map['exercises'] is List<dynamic> =>
        map['exercises'] as List<dynamic>,
      _ => throw const FormatException('Invalid exercise media manifest.'),
    };

    final Map<String, ExerciseMedia> unique = <String, ExerciseMedia>{};
    for (final dynamic row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }
      final ExerciseMedia media = ExerciseMedia.fromJson(row);
      if (media.exerciseId.isEmpty || !media.hasVideo) {
        continue;
      }
      unique[media.exerciseId] = media;
    }
    return unique.values.toList(growable: false);
  }
}
