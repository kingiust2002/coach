import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/database/app_database.dart';
import '../features/athletes/data/athlete_repository.dart';
import '../features/athletes/data/memory_athlete_repository.dart';
import '../features/athletes/data/sqlite_athlete_repository.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/data/memory_exercise_repository.dart';
import '../features/exercises/data/sqlite_exercise_repository.dart';
import 'coach_app.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<_AppDependencies> _initialization = _initialize();

  Future<_AppDependencies> _initialize() async {
    if (kIsWeb) {
      return _AppDependencies(
        athleteRepository: MemoryAthleteRepository(),
        exerciseRepository: MemoryExerciseRepository(),
      );
    }

    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final AppDatabase database = AppDatabase.instance;
    await database.open();
    return _AppDependencies(
      athleteRepository: SqliteAthleteRepository(database),
      exerciseRepository: SqliteExerciseRepository(database),
    );
  }

  void _retry() {
    setState(() {
      _initialization = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppDependencies>(
      future: _initialization,
      builder: (
        BuildContext context,
        AsyncSnapshot<_AppDependencies> snapshot,
      ) {
        final _AppDependencies? dependencies = snapshot.data;
        if (dependencies != null) {
          return CoachApp(
            athleteRepository: dependencies.athleteRepository,
            exerciseRepository: dependencies.exerciseRepository,
          );
        }

        if (snapshot.hasError) {
          return _BootstrapFrame(
            child: _StartupError(
              error: snapshot.error,
              onRetry: _retry,
            ),
          );
        }

        return const _BootstrapFrame(child: _StartupLoading());
      },
    );
  }
}

class _AppDependencies {
  const _AppDependencies({
    required this.athleteRepository,
    required this.exerciseRepository,
  });

  final AthleteRepository athleteRepository;
  final ExerciseRepository exerciseRepository;
}

class _BootstrapFrame extends StatelessWidget {
  const _BootstrapFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مربی‌یار',
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: SafeArea(child: child)),
      ),
    );
  }
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('در حال آماده‌سازی مربی‌یار…'),
        ],
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'راه‌اندازی برنامه کامل نشد',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'اطلاعات برنامه حذف نشده است. دوباره تلاش کنید و در صورت تکرار، متن خطای زیر را ارسال کنید.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    error?.toString() ?? 'خطای ناشناخته',
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش دوباره'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
