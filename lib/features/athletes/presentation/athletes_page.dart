import 'package:flutter/material.dart';

import '../domain/athlete.dart';
import 'athlete_detail_page.dart';
import 'athlete_form_page.dart';
import 'athletes_controller.dart';

enum _AthleteListFilter { active, archived, all }

class AthletesPage extends StatefulWidget {
  const AthletesPage({required this.controller, super.key});

  final AthletesController controller;

  @override
  State<AthletesPage> createState() => _AthletesPageState();
}

class _AthletesPageState extends State<AthletesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _AthleteListFilter _filter = _AthleteListFilter.active;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final List<Athlete> visible = widget.controller.athletes
            .where(_matchesStatus)
            .where(_matchesQuery)
            .toList(growable: false);

        return Scaffold(
          appBar: AppBar(
            title: const Text('شاگردان'),
            actions: <Widget>[
              IconButton(
                tooltip: 'تازه‌سازی',
                onPressed: widget.controller.isLoading
                    ? null
                    : widget.controller.load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: widget.controller.isMutating
                ? null
                : () => _openForm(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('شاگرد جدید'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (String value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: 'نام، شماره، هدف یا محیط تمرین',
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'پاک‌کردن جست‌وجو',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              _StatusFilters(
                value: _filter,
                activeCount: widget.controller.activeCount,
                archivedCount: widget.controller.archivedCount,
                onChanged: (_AthleteListFilter value) {
                  setState(() => _filter = value);
                },
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(context, visible)),
            ],
          ),
        );
      },
    );
  }

  bool _matchesStatus(Athlete athlete) {
    switch (_filter) {
      case _AthleteListFilter.active:
        return athlete.isActive;
      case _AthleteListFilter.archived:
        return !athlete.isActive;
      case _AthleteListFilter.all:
        return true;
    }
  }

  bool _matchesQuery(Athlete athlete) {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    return athlete.fullName.toLowerCase().contains(query) ||
        athlete.phone.contains(query) ||
        athlete.goal.toLowerCase().contains(query) ||
        athlete.primaryGoal.label.toLowerCase().contains(query) ||
        athlete.trainingLevel.label.toLowerCase().contains(query) ||
        athlete.trainingEnvironment.label.toLowerCase().contains(query);
  }

  Widget _buildBody(BuildContext context, List<Athlete> athletes) {
    if (widget.controller.isLoading && widget.controller.athletes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.controller.error != null && widget.controller.athletes.isEmpty) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'خواندن اطلاعات انجام نشد',
        description: 'دوباره تلاش کنید. اطلاعات موجود حذف نشده‌اند.',
        actionLabel: 'تلاش دوباره',
        onAction: widget.controller.load,
      );
    }

    if (athletes.isEmpty) {
      final bool noAthletesAtAll = widget.controller.athletes.isEmpty;
      return _EmptyState(
        icon: noAthletesAtAll
            ? Icons.group_add_outlined
            : Icons.manage_search_rounded,
        title: noAthletesAtAll
            ? 'هنوز شاگردی ثبت نشده'
            : 'شاگردی با این فیلتر پیدا نشد',
        description: noAthletesAtAll
            ? 'اولین پرونده را بسازید تا ارزیابی و برنامه‌ها به آن متصل شوند.'
            : 'عبارت جست‌وجو یا وضعیت انتخاب‌شده را تغییر دهید.',
        actionLabel: noAthletesAtAll ? 'ثبت اولین شاگرد' : null,
        onAction: noAthletesAtAll ? () => _openForm(context) : null,
      );
    }

    return RefreshIndicator(
      onRefresh: widget.controller.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: athletes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final Athlete athlete = athletes[index];
          return _AthleteCard(
            athlete: athlete,
            onTap: () => _openDetails(context, athlete),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            AthleteFormPage(controller: widget.controller),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, Athlete athlete) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AthleteDetailPage(
          controller: widget.controller,
          athleteId: athlete.id,
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.value,
    required this.activeCount,
    required this.archivedCount,
    required this.onChanged,
  });

  final _AthleteListFilter value;
  final int activeCount;
  final int archivedCount;
  final ValueChanged<_AthleteListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          _FilterChip(
            label: 'فعال',
            count: activeCount,
            selected: value == _AthleteListFilter.active,
            icon: Icons.check_circle_outline_rounded,
            onTap: () => onChanged(_AthleteListFilter.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'بایگانی',
            count: archivedCount,
            selected: value == _AthleteListFilter.archived,
            icon: Icons.inventory_2_outlined,
            onTap: () => onChanged(_AthleteListFilter.archived),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'همه',
            count: activeCount + archivedCount,
            selected: value == _AthleteListFilter.all,
            icon: Icons.groups_outlined,
            onTap: () => onChanged(_AthleteListFilter.all),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? colors.primary : colors.onSurface,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AthleteCard extends StatelessWidget {
  const _AthleteCard({required this.athlete, required this.onTap});

  final Athlete athlete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String initial = athlete.fullName.trim().isEmpty
        ? '؟'
        : athlete.fullName.trim().characters.first;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: athlete.isActive
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: athlete.isActive
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            athlete.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (!athlete.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'بایگانی',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${athlete.primaryGoal.label} • ${athlete.trainingLevel.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      children: <Widget>[
                        _MiniTag(
                          icon: Icons.calendar_view_week_rounded,
                          label: '${athlete.preferredDaysPerWeek} روز',
                        ),
                        _MiniTag(
                          icon: Icons.timer_outlined,
                          label: '${athlete.preferredSessionMinutes} دقیقه',
                        ),
                        _MiniTag(
                          icon: Icons.location_on_outlined,
                          label: athlete.trainingEnvironment.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_left_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(icon, size: 42, color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
