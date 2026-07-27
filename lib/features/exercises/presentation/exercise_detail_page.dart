import 'package:flutter/material.dart';

import '../domain/exercise.dart';
import 'exercise_form_page.dart';
import 'exercises_controller.dart';

class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({
    required this.exerciseId,
    required this.controller,
    super.key,
  });

  final String exerciseId;
  final ExercisesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final Exercise? exercise = controller.byId(exerciseId);
        if (exercise == null) {
          return const Scaffold(
            body: Center(child: Text('حرکت پیدا نشد.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(exercise.nameFa),
            actions: <Widget>[
              if (!exercise.isSystem)
                IconButton(
                  tooltip: 'ویرایش',
                  onPressed: controller.isMutating
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => ExerciseFormPage(
                                controller: controller,
                                exercise: exercise,
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              PopupMenuButton<String>(
                onSelected: (String value) => _handleAction(
                  context,
                  exercise,
                  value,
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: exercise.isActive ? 'archive' : 'restore',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          exercise.isActive
                              ? Icons.archive_outlined
                              : Icons.restore_rounded,
                        ),
                        const SizedBox(width: 10),
                        Text(exercise.isActive ? 'بایگانی' : 'بازیابی'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              _Header(exercise: exercise),
              const SizedBox(height: 16),
              _InfoSection(
                title: 'طبقه‌بندی',
                icon: Icons.category_outlined,
                rows: <MapEntry<String, String>>[
                  MapEntry<String, String>(
                    'عضله اصلی',
                    exercise.primaryMuscle.label,
                  ),
                  MapEntry<String, String>(
                    'عضلات فرعی',
                    exercise.secondaryMuscles.isEmpty
                        ? '—'
                        : exercise.secondaryMuscles
                            .map((MuscleGroup item) => item.label)
                            .join('، '),
                  ),
                  MapEntry<String, String>('نوع حرکت', exercise.type.label),
                  MapEntry<String, String>('وسیله', exercise.equipment.label),
                  MapEntry<String, String>(
                    'سطح دشواری',
                    exercise.difficulty.label,
                  ),
                  MapEntry<String, String>(
                    'الگوی حرکتی',
                    exercise.movementPattern.label,
                  ),
                  MapEntry<String, String>(
                    'اجرای طرفین',
                    exercise.laterality.label,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _TextSection(
                title: 'راهنمای اجرا',
                icon: Icons.menu_book_outlined,
                text: exercise.instructions,
                emptyText: 'راهنمای اجرا ثبت نشده است.',
              ),
              const SizedBox(height: 16),
              _TextSection(
                title: 'نکات ایمنی',
                icon: Icons.health_and_safety_outlined,
                text: exercise.safetyNotes,
                emptyText: 'نکته ایمنی ثبت نشده است.',
              ),
              if (exercise.coachNotes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _TextSection(
                  title: 'یادداشت خصوصی مربی',
                  icon: Icons.lock_outline_rounded,
                  text: exercise.coachNotes,
                  emptyText: '',
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'شناسه پایدار حرکت: ${exercise.id}\nاین شناسه در برنامه‌ساز ذخیره می‌شود و بایگانی حرکت، برنامه‌های قبلی را نمی‌شکند.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Exercise exercise,
    String action,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(action == 'archive' ? 'بایگانی حرکت' : 'بازیابی حرکت'),
        content: Text(
          action == 'archive'
              ? 'حرکت از انتخاب‌های جدید پنهان می‌شود، اما شناسه و ارجاع‌های قبلی آن حفظ خواهد شد.'
              : 'حرکت دوباره در کتابخانه فعال نمایش داده شود؟',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action == 'archive' ? 'بایگانی' : 'بازیابی'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      action == 'archive'
          ? await controller.archive(exercise)
          : await controller.restore(exercise);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عملیات انجام نشد.')),
        );
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  child: const Icon(Icons.fitness_center_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        exercise.nameFa,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (exercise.nameEn.isNotEmpty)
                        Text(
                          exercise.nameEn,
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(
                  avatar: Icon(
                    exercise.isSystem
                        ? Icons.verified_outlined
                        : Icons.person_outline_rounded,
                    size: 18,
                  ),
                  label: Text(exercise.isSystem ? 'سیستمی' : 'سفارشی'),
                ),
                Chip(label: Text(exercise.primaryMuscle.label)),
                Chip(label: Text(exercise.equipment.label)),
                Chip(label: Text(exercise.difficulty.label)),
                Chip(
                  backgroundColor: exercise.isActive
                      ? colors.primaryContainer
                      : colors.errorContainer,
                  label: Text(exercise.isActive ? 'فعال' : 'بایگانی‌شده'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<MapEntry<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(title: title, icon: icon),
            const SizedBox(height: 12),
            for (final MapEntry<String, String> row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 110,
                      child: Text(
                        row.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({
    required this.title,
    required this.icon,
    required this.text,
    required this.emptyText,
  });

  final String title;
  final IconData icon;
  final String text;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(title: title, icon: icon),
            const SizedBox(height: 12),
            Text(text.isEmpty ? emptyText : text),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
