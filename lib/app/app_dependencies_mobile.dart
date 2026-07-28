import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/media_config.dart';
import '../core/database/app_database.dart';
import '../features/athletes/data/sqlite_athlete_repository.dart';
import '../features/exercises/data/exercise_video_store.dart';
import '../features/exercises/data/remote_exercise_media_catalog.dart';
import '../features/exercises/data/sqlite_exercise_repository.dart';
import 'app_dependencies.dart';

Future<AppDependencies> createAppDependencies() async {
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final AppDatabase database = AppDatabase.instance;
  await database.open();
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return AppDependencies(
    athleteRepository: SqliteAthleteRepository(database),
    exerciseRepository: SqliteExerciseRepository(database),
    exerciseMediaCatalog: RemoteExerciseMediaCatalog(
      endpoint: MediaConfig.exerciseManifestUri,
      preferences: preferences,
    ),
    exerciseVideoStore: createExerciseVideoStore(),
  );
}
