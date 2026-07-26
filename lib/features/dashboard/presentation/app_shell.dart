import 'package:flutter/material.dart';

import '../../athletes/presentation/athletes_controller.dart';
import '../../athletes/presentation/athletes_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.controller,
    super.key,
  });

  final AthletesController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _Dashboard(controller: widget.controller),
      AthletesPage(controller: widget.controller),
      const _ComingSoon(
        title: 'برنامه‌ها',
        description: 'برنامه‌ساز نسخه‌دار در مرحله بعد اضافه می‌شود.',
        icon: Icons.assignment_outlined,
      ),
      const _ComingSoon(
        title: 'تنظیمات',
        description: 'پشتیبان‌گیری و تبادل آفلاین در این بخش قرار می‌گیرد.',
        icon: Icons.settings_outlined,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
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
  const _Dashboard({required this.controller});

  final AthletesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'مربی‌یار',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'مدیریت دقیق شاگردها و برنامه‌های تمرینی',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _StatCard(
              icon: Icons.groups_2_outlined,
              title: 'شاگرد فعال',
              value: controller.activeCount.toString(),
            ),
            const SizedBox(height: 16),
            const _InfoCard(
              title: 'پایه آفلاین فعال است',
              description:
                  'اطلاعات روی دستگاه ذخیره می‌شود. نسخه‌بندی و تبادل فایل در مراحل بعد روی همین هسته اضافه خواهد شد.',
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
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            CircleAvatar(radius: 26, child: Icon(icon)),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
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
