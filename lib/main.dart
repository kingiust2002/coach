import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/coach_app.dart';
import 'core/database/app_database.dart';
import 'features/athletes/data/sqlite_athlete_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final AppDatabase database = AppDatabase.instance;
  await database.open();

  runApp(
    CoachApp(
      athleteRepository: SqliteAthleteRepository(database),
    ),
  );
}
