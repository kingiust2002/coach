import 'package:flutter/material.dart';

import '../../athletes/presentation/athletes_controller.dart';
import '../../athletes/presentation/athletes_page.dart';
import '../../exercises/presentation/exercises_controller.dart';
import '../../exercises/presentation/exercises_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.athletesController,
    required this.exercisesController,
    super.key,
  });

  final AthletesController athletesController;
  final ExercisesController exercisesController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _Dashboard(
        athletesController: widget.athletesController,
        exercisesController: widget.exercisesController,
        openAthletes: () => setState(() => _index = 1),
        openExercises: () => setState(() => _index = 2),
      ),
      AthletesPage(controller: widget.athletesController),
      ExercisesPage(controller: widget.exercisesController),
      const _ComingSoon(
        title: 'برنامه‌ها',
        description:
            'پس از تکمیل ارزیابی شاگرد، برنامه‌ساز Draft به کتابخانه حرکات متصل می‌شود.',
        icon: Icons.assignment_outlined,
      ),
      const _ComingSoon(
        title: 'تنظیمات',
        description: 'پشتیبان‌گیری و تبادل آفلاین در این بخش قرار می‌گیرد.',
        icon: Icons.settings_outlined,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'شاگردان',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'حرکات',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'برنامه‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.athletesController,
    required this.exercisesController,
    required this.openAthletes,
    required this.openExercises,
  });

  final AthletesController athletesController;
  final ExercisesController exercisesController;
  final VoidCallback openAthletes;
  final VoidCallback openExercises;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        athletesController,
        exercisesController,
      ]),
      builder: (BuildContext context, Widget? child) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'مربی‌یار',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'مدیریت دقیق شاگردها، حرکات و برنامه‌های تمرینی',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    icon: Icons.groups_2_outlined,
                    title: 'شاگرد فعال',
                    value: athletesController.activeCount.toString(),
                    onTap: openAthletes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.fitness_center_rounded,
                    title: 'حرکت فعال',
                    value: exercisesController.activeCount.toString(),
                    onTap: openExercises,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'کتابخانه حرکات آماده برنامه‌ساز است',
              description:
                  '${exercisesController.systemCount} حرکت سیستمی و ${exercisesController.customCount} حرکت سفارشی با شناسه پایدار در دسترس است. حرکت بایگانی‌شده حذف نمی‌شود و ارجاع برنامه‌های آینده را حفظ می‌کند.',
            ),
            const SizedBox(height: 16),
            const _InfoCard(
              title: 'چرخه محصول',
              description:
                  'شاگرد ← ارزیابی ← انتخاب حرکت ← برنامه ← اجرا ← گزارش ← بازبینی',
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(radius: 23, child: Icon(icon)),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
