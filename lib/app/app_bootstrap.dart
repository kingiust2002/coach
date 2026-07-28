import 'package:flutter/material.dart';

import 'app_dependencies.dart';
import 'app_dependencies_mobile.dart'
    if (dart.library.html) 'app_dependencies_web.dart'
    as platform;
import 'coach_app.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<AppDependencies> _initialization = _initialize();

  Future<AppDependencies> _initialize() => platform.createAppDependencies();

  void _retry() {
    setState(() {
      _initialization = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _initialization,
      builder: (BuildContext context, AsyncSnapshot<AppDependencies> snapshot) {
        final AppDependencies? dependencies = snapshot.data;
        if (dependencies != null) {
          return CoachApp(
            athleteRepository: dependencies.athleteRepository,
            exerciseRepository: dependencies.exerciseRepository,
            exerciseMediaRepository: dependencies.exerciseMediaRepository,
            exerciseMediaDownloader: dependencies.exerciseMediaDownloader,
          );
        }

        if (snapshot.hasError) {
          return _BootstrapFrame(
            child: _StartupError(error: snapshot.error, onRetry: _retry),
          );
        }

        return const _BootstrapFrame(child: _StartupLoading());
      },
    );
  }
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
