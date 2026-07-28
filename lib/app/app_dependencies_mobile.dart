import 'package:flutter/services.dart';

import '../core/database/app_database.dart';
import '../features/athletes/data/sqlite_athlete_repository.dart';
import '../features/exercises/data/exercise_media_downloader_mobile.dart';
import '../features/exercises/data/sqlite_exercise_media_repository.dart';
import '../features/exercises/data/sqlite_exercise_repository.dart';
import 'app_dependencies.dart';

Future<AppDependencies> createAppDependencies() async {
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final AppDatabase database = AppDatabase.instance;
  await database.open();
  return AppDependencies(
    athleteRepository: SqliteAthleteRepository(database),
    exerciseRepository: SqliteExerciseRepository(database),
    exerciseMediaRepository: SqliteExerciseMediaRepository(database),
    exerciseMediaDownloader: createExerciseMediaDownloader(),
  );
}
