import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/athletes/data/athlete_repository.dart';
import '../features/athletes/presentation/athletes_controller.dart';
import '../features/dashboard/presentation/app_shell.dart';
import 'theme/app_theme.dart';

class CoachApp extends StatefulWidget {
  const CoachApp({
    required this.athleteRepository,
    super.key,
  });

  final AthleteRepository athleteRepository;

  @override
  State<CoachApp> createState() => _CoachAppState();
}

class _CoachAppState extends State<CoachApp> {
  late final AthletesController _athletesController;

  @override
  void initState() {
    super.initState();
    _athletesController = AthletesController(widget.athleteRepository);
    unawaited(_athletesController.load());
  }

  @override
  void dispose() {
    _athletesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مربی‌یار',
      locale: const Locale('fa'),
      supportedLocales: const <Locale>[
        Locale('fa'),
        Locale('en'),
      ],
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
        child: AppShell(controller: _athletesController),
      ),
    );
  }
}
