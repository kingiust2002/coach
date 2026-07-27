import 'package:flutter/material.dart';

import '../domain/exercise.dart';
import 'exercise_detail_page.dart';
import 'exercise_form_page.dart';
import 'exercises_controller.dart';

enum ExerciseStatusFilter {
  active('فعال'),
  archived('بایگانی'),
  all('همه');

  const ExerciseStatusFilter(this.label);
  final String label;
}

enum ExerciseSourceFilter {
  all('همه منابع'),
  system('سیستمی'),
  custom('سفارشی');

  const ExerciseSourceFilter(this.label);
  final String label;
}

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({required this.controller, super.key});

  final ExercisesController controller;

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final TextEditingController _search = TextEditingController();
  ExerciseStatusFilter _status = ExerciseStatusFilter.active;
  ExerciseSourceFilter _source = ExerciseSourceFilter.all;
  MuscleGroup? _muscle;
  ExerciseEquipment? _equipment;
  ExerciseType? _type;
  ExerciseDifficulty? _difficulty;

  bool get _hasAdvancedFilters =>
      _source != ExerciseSourceFilter.all ||
      _muscle != null ||
      _equipment != null ||
      _type != null ||
      _difficulty != null;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
  }

  @override
  void dispose() {
    _search
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final List<Exercise> filtered = _filteredExercises();
        return Scaffold(
          appBar: AppBar(
            title: const Text('کتابخانه حرکات'),
            actions: <Widget>[
              IconButton(
                tooltip: 'بازخوانی',
                onPressed: widget.controller.isLoading
                    ? null
                    : widget.controller.load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'جست‌وجوی نام، عضله، وسیله یا الگو',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'پاک‌کردن جست‌وجو',
                              onPressed: _search.clear,
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      for (final ExerciseStatusFilter item
                          in ExerciseStatusFilter.values)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(item.label),
                            selected: _status == item,
                            onSelected: (_) => setState(() => _status = item),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: FilterChip(
                          avatar: const Icon(Icons.tune_rounded, size: 18),
                          label: Text(
                            _hasAdvancedFilters ? 'فیلترها فعال' : 'فیلترها',
                          ),
                          selected: _hasAdvancedFilters,
                          onSelected: (_) => _openFilters(),
                        ),
                      ),
                      if (_hasAdvancedFilters)
                        ActionChip(
                          avatar: const Icon(
                            Icons.filter_alt_off_outlined,
                            size: 18,
                          ),
                          label: const Text('پاک‌کردن'),
                          onPressed: _clearAdvancedFilters,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _CatalogSummary(
                    visibleCount: filtered.length,
                    activeCount: widget.controller.activeCount,
                    customCount: widget.controller.customCount,
                    systemCount: widget.controller.systemCount,
                  ),
                ),
                Expanded(child: _buildBody(filtered)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: widget.controller.isMutating ? null : _createExercise,
            icon: const Icon(Icons.add_rounded),
            label: const Text('حرکت سفارشی'),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<Exercise> exercises) {
    if (widget.controller.isLoading && widget.controller.exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.controller.error != null &&
        widget.controller.exercises.isEmpty) {
      return _EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'بارگذاری کتابخانه انجام نشد',
        description: 'دوباره تلاش کنید.',
        actionLabel: 'تلاش مجدد',
        onAction: widget.controller.load,
      );
    }
    if (exercises.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'حرکتی با این شرایط پیدا نشد',
        description: 'جست‌وجو یا فیلترها را تغییر دهید.',
        actionLabel: _hasAdvancedFilters || _search.text.isNotEmpty
            ? 'پاک‌کردن فیلترها'
            : 'ساخت حرکت سفارشی',
        onAction: _hasAdvancedFilters || _search.text.isNotEmpty
            ? () {
                _search.clear();
                _clearAdvancedFilters();
              }
            : _createExercise,
      );
    }
    return RefreshIndicator(
      onRefresh: widget.controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final Exercise exercise = exercises[index];
          return _ExerciseCard(
            exercise: exercise,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => ExerciseDetailPage(
                  exerciseId: exercise.id,
                  controller: widget.controller,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Exercise> _filteredExercises() {
    final String query = _normalized(_search.text);
    return widget.controller.exercises
        .where((Exercise exercise) {
          final bool statusMatches = switch (_status) {
            ExerciseStatusFilter.active => exercise.isActive,
            ExerciseStatusFilter.archived => !exercise.isActive,
            ExerciseStatusFilter.all => true,
          };
          final bool sourceMatches = switch (_source) {
            ExerciseSourceFilter.all => true,
            ExerciseSourceFilter.system => exercise.isSystem,
            ExerciseSourceFilter.custom => !exercise.isSystem,
          };
          final bool queryMatches =
              query.isEmpty ||
              _normalized(
                <String>[
                  exercise.nameFa,
                  exercise.nameEn,
                  exercise.primaryMuscle.label,
                  ...exercise.secondaryMuscles.map(
                    (MuscleGroup item) => item.label,
                  ),
                  exercise.equipment.label,
                  exercise.type.label,
                  exercise.movementPattern.label,
                ].join(' '),
              ).contains(query);
          return statusMatches &&
              sourceMatches &&
              queryMatches &&
              (_muscle == null ||
                  exercise.primaryMuscle == _muscle ||
                  exercise.secondaryMuscles.contains(_muscle)) &&
              (_equipment == null || exercise.equipment == _equipment) &&
              (_type == null || exercise.type == _type) &&
              (_difficulty == null || exercise.difficulty == _difficulty);
        })
        .toList(growable: false);
  }

  String _normalized(String value) => value
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  Future<void> _createExercise() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ExerciseFormPage(controller: widget.controller),
      ),
    );
  }

  Future<void> _openFilters() async {
    final _FilterSelection? result =
        await showModalBottomSheet<_FilterSelection>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (BuildContext context) => _FilterSheet(
            initial: _FilterSelection(
              source: _source,
              muscle: _muscle,
              equipment: _equipment,
              type: _type,
              difficulty: _difficulty,
            ),
          ),
        );
    if (result == null) {
      return;
    }
    setState(() {
      _source = result.source;
      _muscle = result.muscle;
      _equipment = result.equipment;
      _type = result.type;
      _difficulty = result.difficulty;
    });
  }

  void _clearAdvancedFilters() {
    setState(() {
      _source = ExerciseSourceFilter.all;
      _muscle = null;
      _equipment = null;
      _type = null;
      _difficulty = null;
    });
  }
}

class _CatalogSummary extends StatelessWidget {
  const _CatalogSummary({
    required this.visibleCount,
    required this.activeCount,
    required this.customCount,
    required this.systemCount,
  });

  final int visibleCount;
  final int activeCount;
  final int customCount;
  final int systemCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.library_books_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text('$visibleCount نتیجه')),
            Text(
              '$activeCount فعال · $systemCount سیستمی · $customCount سفارشی',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: exercise.isActive
                      ? colors.primaryContainer
                      : colors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: exercise.isActive
                      ? colors.onPrimaryContainer
                      : colors.onErrorContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            exercise.nameFa,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Icon(
                          exercise.isSystem
                              ? Icons.verified_outlined
                              : Icons.person_outline_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    if (exercise.nameEn.isNotEmpty)
                      Text(
                        exercise.nameEn,
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        _MiniTag(exercise.primaryMuscle.label),
                        _MiniTag(exercise.equipment.label),
                        _MiniTag(exercise.difficulty.label),
                        if (!exercise.isActive) const _MiniTag('بایگانی'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _FilterSelection {
  const _FilterSelection({
    required this.source,
    required this.muscle,
    required this.equipment,
    required this.type,
    required this.difficulty,
  });

  final ExerciseSourceFilter source;
  final MuscleGroup? muscle;
  final ExerciseEquipment? equipment;
  final ExerciseType? type;
  final ExerciseDifficulty? difficulty;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final _FilterSelection initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ExerciseSourceFilter _source;
  MuscleGroup? _muscle;
  ExerciseEquipment? _equipment;
  ExerciseType? _type;
  ExerciseDifficulty? _difficulty;

  @override
  void initState() {
    super.initState();
    _source = widget.initial.source;
    _muscle = widget.initial.muscle;
    _equipment = widget.initial.equipment;
    _type = widget.initial.type;
    _difficulty = widget.initial.difficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'فیلتر کتابخانه',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExerciseSourceFilter>(
              value: _source,
              decoration: const InputDecoration(labelText: 'منبع حرکت'),
              items: ExerciseSourceFilter.values
                  .map(
                    (ExerciseSourceFilter item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(growable: false),
              onChanged: (ExerciseSourceFilter? value) {
                if (value != null) {
                  setState(() => _source = value);
                }
              },
            ),
            const SizedBox(height: 12),
            _NullableDropdown<MuscleGroup>(
              label: 'عضله',
              value: _muscle,
              values: MuscleGroup.values,
              text: (MuscleGroup item) => item.label,
              onChanged: (MuscleGroup? value) =>
                  setState(() => _muscle = value),
            ),
            const SizedBox(height: 12),
            _NullableDropdown<ExerciseEquipment>(
              label: 'وسیله',
              value: _equipment,
              values: ExerciseEquipment.values,
              text: (ExerciseEquipment item) => item.label,
              onChanged: (ExerciseEquipment? value) =>
                  setState(() => _equipment = value),
            ),
            const SizedBox(height: 12),
            _NullableDropdown<ExerciseType>(
              label: 'نوع حرکت',
              value: _type,
              values: ExerciseType.values,
              text: (ExerciseType item) => item.label,
              onChanged: (ExerciseType? value) => setState(() => _type = value),
            ),
            const SizedBox(height: 12),
            _NullableDropdown<ExerciseDifficulty>(
              label: 'سطح دشواری',
              value: _difficulty,
              values: ExerciseDifficulty.values,
              text: (ExerciseDifficulty item) => item.label,
              onChanged: (ExerciseDifficulty? value) =>
                  setState(() => _difficulty = value),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _source = ExerciseSourceFilter.all;
                      _muscle = null;
                      _equipment = null;
                      _type = null;
                      _difficulty = null;
                    }),
                    child: const Text('پاک‌کردن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _FilterSelection(
                        source: _source,
                        muscle: _muscle,
                        equipment: _equipment,
                        type: _type,
                        difficulty: _difficulty,
                      ),
                    ),
                    child: const Text('اعمال فیلتر'),
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

class _NullableDropdown<T> extends StatelessWidget {
  const _NullableDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.text,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T item) text;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: <DropdownMenuItem<T?>>[
        DropdownMenuItem<T?>(value: null, child: const Text('همه')),
        ...values.map(
          (T item) =>
              DropdownMenuItem<T?>(value: item, child: Text(text(item))),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
