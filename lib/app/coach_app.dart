import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../features/athletes/data/athlete_repository.dart';
import '../features/athletes/presentation/athletes_controller.dart';
import '../features/dashboard/presentation/app_shell.dart';
import '../features/exercises/data/exercise_media_downloader.dart';
import '../features/exercises/data/exercise_media_repository.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/presentation/exercise_media_controller.dart';
import '../features/exercises/presentation/exercises_controller.dart';
import 'theme/app_theme.dart';

class CoachApp extends StatefulWidget {
  const CoachApp({
    required this.athleteRepository,
    required this.exerciseRepository,
    required this.exerciseMediaRepository,
    required this.exerciseMediaDownloader,
    super.key,
  });

  final AthleteRepository athleteRepository;
  final ExerciseRepository exerciseRepository;
  final ExerciseMediaRepository exerciseMediaRepository;
  final ExerciseMediaDownloader exerciseMediaDownloader;

  @override
  State<CoachApp> createState() => _CoachAppState();
}

class _CoachAppState extends State<CoachApp> {
  late final AthletesController _athletesController;
  late final ExercisesController _exercisesController;
  late final ExerciseMediaController _exerciseMediaController;

  @override
  void initState() {
    super.initState();
    _athletesController = AthletesController(widget.athleteRepository);
    _exercisesController = ExercisesController(widget.exerciseRepository);
    _exerciseMediaController = ExerciseMediaController(
      exerciseRepository: widget.exerciseRepository,
      mediaRepository: widget.exerciseMediaRepository,
      downloader: widget.exerciseMediaDownloader,
    );
    unawaited(_athletesController.load());
    unawaited(_exercisesController.load());
    unawaited(_exerciseMediaController.load());
  }

  @override
  void dispose() {
    _athletesController.dispose();
    _exercisesController.dispose();
    _exerciseMediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مربی‌یار',
      locale: const Locale('fa', 'IR'),
      supportedLocales: const <Locale>[
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        PersianMaterialLocalizations.delegate,
        PersianCupertinoLocalizations.delegate,
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
          exerciseMediaController: _exerciseMediaController,
        ),
      ),
    );
  }
}
