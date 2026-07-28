import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/athletes/data/athlete_repository.dart';
import '../features/athletes/presentation/athletes_controller.dart';
import '../features/dashboard/presentation/app_shell.dart';
import '../features/exercises/data/exercise_media_catalog.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/data/exercise_video_store_base.dart';
import '../features/exercises/presentation/exercises_controller.dart';
import 'theme/app_theme.dart';

class CoachApp extends StatefulWidget {
  const CoachApp({
    required this.athleteRepository,
    required this.exerciseRepository,
    this.exerciseMediaCatalog,
    this.exerciseVideoStore,
    super.key,
  });

  final AthleteRepository athleteRepository;
  final ExerciseRepository exerciseRepository;
  final ExerciseMediaCatalog? exerciseMediaCatalog;
  final ExerciseVideoStore? exerciseVideoStore;

  @override
  State<CoachApp> createState() => _CoachAppState();
}

class _CoachAppState extends State<CoachApp> {
  late final AthletesController _athletesController;
  late final ExercisesController _exercisesController;

  @override
  void initState() {
    super.initState();
    _athletesController = AthletesController(widget.athleteRepository);
    _exercisesController = ExercisesController(
      widget.exerciseRepository,
      mediaCatalog: widget.exerciseMediaCatalog,
      videoStore: widget.exerciseVideoStore,
    );
    unawaited(_athletesController.load());
    unawaited(_exercisesController.load());
  }

  @override
  void dispose() {
    _athletesController.dispose();
    _exercisesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مربی‌یار',
      locale: const Locale('fa'),
      supportedLocales: const <Locale>[Locale('fa'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: AppShell(
          athletesController: _athletesController,
          exercisesController: _exercisesController,
        ),
      ),
    );
  }
}
