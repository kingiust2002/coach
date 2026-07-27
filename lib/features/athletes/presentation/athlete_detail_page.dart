import 'package:flutter/material.dart';

import '../domain/athlete.dart';
import 'athlete_form_page.dart';
import 'athletes_controller.dart';

class AthleteDetailPage extends StatelessWidget {
  const AthleteDetailPage({
    required this.controller,
    required this.athleteId,
    super.key,
  });

  final AthletesController controller;
  final String athleteId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final Athlete? athlete = controller.byId(athleteId);
        if (athlete == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('پرونده شاگرد')),
            body: const Center(child: Text('پرونده شاگرد پیدا نشد.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('پرونده شاگرد'),
            actions: <Widget>[
              IconButton(
                tooltip: 'ویرایش پرونده',
                onPressed: controller.isMutating
                    ? null
                    : () => _openEdit(context, athlete),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: <Widget>[
                _ProfileHeader(athlete: athlete),
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'اطلاعات پایه',
                  icon: Icons.badge_outlined,
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      label: 'شماره تماس',
                      value: athlete.phone.isEmpty ? 'ثبت نشده' : athlete.phone,
                      textDirection: athlete.phone.isEmpty
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                    _DetailRowData(
                      label: 'تاریخ تولد',
                      value: _birthDateLabel(athlete.birthDate),
                    ),
                    _DetailRowData(label: 'سن', value: _ageLabel(athlete)),
                    _DetailRowData(
                      label: 'تاریخ ایجاد پرونده',
                      value: _dateLabel(athlete.createdAt),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'هدف و تجربه تمرینی',
                  icon: Icons.track_changes_rounded,
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      label: 'هدف اصلی',
                      value: athlete.primaryGoal.label,
                    ),
                    _DetailRowData(
                      label: 'توضیح هدف',
                      value: athlete.goal.isEmpty ? 'ثبت نشده' : athlete.goal,
                    ),
                    _DetailRowData(
                      label: 'سطح تمرینی',
                      value: athlete.trainingLevel.label,
                    ),
                    _DetailRowData(
                      label: 'سابقه تمرین منظم',
                      value: '${athlete.experienceMonths} ماه',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'ترجیحات برنامه',
                  icon: Icons.tune_rounded,
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      label: 'روزهای تمرین',
                      value: '${athlete.preferredDaysPerWeek} روز در هفته',
                    ),
                    _DetailRowData(
                      label: 'مدت هر جلسه',
                      value: '${athlete.preferredSessionMinutes} دقیقه',
                    ),
                    _DetailRowData(
                      label: 'محیط تمرین',
                      value: athlete.trainingEnvironment.label,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'سلامت و محدودیت‌ها',
                  icon: Icons.health_and_safety_outlined,
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      label: 'آسیب‌ها و محدودیت‌های حرکتی',
                      value: athlete.injuries.isEmpty
                          ? 'موردی ثبت نشده'
                          : athlete.injuries,
                    ),
                    _DetailRowData(
                      label: 'ملاحظات پزشکی اعلام‌شده',
                      value: athlete.medicalNotes.isEmpty
                          ? 'موردی ثبت نشده'
                          : athlete.medicalNotes,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'یادداشت مربی',
                  icon: Icons.note_alt_outlined,
                  rows: <_DetailRowData>[
                    _DetailRowData(
                      label: 'یادداشت خصوصی',
                      value: athlete.notes.isEmpty
                          ? 'یادداشتی ثبت نشده'
                          : athlete.notes,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _ConnectedFeaturesCard(),
                const SizedBox(height: 24),
                if (athlete.isActive)
                  OutlinedButton.icon(
                    onPressed: controller.isMutating
                        ? null
                        : () => _confirmArchive(context, athlete),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('بایگانی شاگرد'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: controller.isMutating
                        ? null
                        : () => _restore(context, athlete),
                    icon: const Icon(Icons.unarchive_outlined),
                    label: const Text('بازگرداندن به شاگردان فعال'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEdit(BuildContext context, Athlete athlete) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            AthleteFormPage(controller: controller, athlete: athlete),
      ),
    );
  }

  Future<void> _confirmArchive(BuildContext context, Athlete athlete) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('بایگانی شاگرد'),
        content: Text(
          '«${athlete.fullName}» از فهرست فعال خارج شود؟ هیچ اطلاعاتی حذف نمی‌شود.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('بایگانی'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await controller.archive(athlete);
      } catch (_) {
        if (context.mounted) {
          _showFailure(context, 'بایگانی شاگرد انجام نشد.');
        }
      }
    }
  }

  Future<void> _restore(BuildContext context, Athlete athlete) async {
    try {
      await controller.restore(athlete);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شاگرد به فهرست فعال بازگردانده شد.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showFailure(context, 'بازیابی شاگرد انجام نشد.');
      }
    }
  }

  void _showFailure(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _birthDateLabel(DateTime? value) {
    return value == null ? 'ثبت نشده' : _dateLabel(value);
  }

  static String _ageLabel(Athlete athlete) {
    final int? age = athlete.ageAt(DateTime.now());
    return age == null ? 'ثبت نشده' : '$age سال';
  }

  static String _dateLabel(DateTime value) {
    final DateTime date = value.toLocal();
    return '${date.year.toString().padLeft(4, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.athlete});

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String initial = athlete.fullName.trim().isEmpty
        ? '؟'
        : athlete.fullName.trim().characters.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[
            colors.primaryContainer,
            colors.secondaryContainer.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 34,
                backgroundColor: colors.surface,
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      athlete.fullName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      athlete.primaryGoal.label,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _StatusPill(
                icon: athlete.isActive
                    ? Icons.check_circle_outline_rounded
                    : Icons.inventory_2_outlined,
                label: athlete.isActive ? 'فعال' : 'بایگانی‌شده',
              ),
              _StatusPill(
                icon: Icons.bar_chart_rounded,
                label: athlete.trainingLevel.label,
              ),
              _StatusPill(
                icon: Icons.calendar_view_week_rounded,
                label: '${athlete.preferredDaysPerWeek} روز در هفته',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: colors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 11),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (int index = 0; index < rows.length; index++) ...<Widget>[
              _DetailRow(data: rows[index]),
              if (index != rows.length - 1)
                Divider(height: 24, color: colors.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.label,
    required this.value,
    this.textDirection = TextDirection.rtl,
  });

  final String label;
  final String value;
  final TextDirection textDirection;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final _DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          data.label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 5),
        Text(
          data.value,
          textDirection: data.textDirection,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ConnectedFeaturesCard extends StatelessWidget {
  const _ConnectedFeaturesCard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ادامه پرونده',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'ارزیابی، اندازه‌گیری و برنامه‌های تمرینی در مرحله‌های بعد مستقیماً به همین پرونده متصل می‌شوند.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            const Row(
              children: <Widget>[
                Expanded(
                  child: _FutureFeature(
                    icon: Icons.fact_check_outlined,
                    label: 'ارزیابی',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FutureFeature(
                    icon: Icons.straighten_outlined,
                    label: 'اندازه‌گیری',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _FutureFeature(
                    icon: Icons.assignment_outlined,
                    label: 'برنامه‌ها',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FutureFeature extends StatelessWidget {
  const _FutureFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: colors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
