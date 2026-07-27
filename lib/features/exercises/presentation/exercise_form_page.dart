import 'package:flutter/material.dart';

import '../../../shared/widgets/app_selection_field.dart';
import '../domain/exercise.dart';
import 'exercises_controller.dart';

class ExerciseFormPage extends StatefulWidget {
  const ExerciseFormPage({required this.controller, this.exercise, super.key});

  final ExercisesController controller;
  final Exercise? exercise;

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameFa;
  late final TextEditingController _nameEn;
  late final TextEditingController _instructions;
  late final TextEditingController _safetyNotes;
  late final TextEditingController _coachNotes;

  late MuscleGroup _primaryMuscle;
  late Set<MuscleGroup> _secondaryMuscles;
  late ExerciseType _type;
  late ExerciseEquipment _equipment;
  late ExerciseDifficulty _difficulty;
  late MovementPattern _movementPattern;
  late ExerciseLaterality _laterality;

  bool _saving = false;
  bool _dirty = false;

  bool get _isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    final Exercise? exercise = widget.exercise;
    _nameFa = TextEditingController(text: exercise?.nameFa ?? '');
    _nameEn = TextEditingController(text: exercise?.nameEn ?? '');
    _instructions = TextEditingController(text: exercise?.instructions ?? '');
    _safetyNotes = TextEditingController(text: exercise?.safetyNotes ?? '');
    _coachNotes = TextEditingController(text: exercise?.coachNotes ?? '');
    _primaryMuscle = exercise?.primaryMuscle ?? MuscleGroup.chest;
    _secondaryMuscles = Set<MuscleGroup>.from(
      exercise?.secondaryMuscles ?? <MuscleGroup>{},
    );
    _type = exercise?.type ?? ExerciseType.compound;
    _equipment = exercise?.equipment ?? ExerciseEquipment.bodyweight;
    _difficulty = exercise?.difficulty ?? ExerciseDifficulty.beginner;
    _movementPattern = exercise?.movementPattern ?? MovementPattern.squat;
    _laterality = exercise?.laterality ?? ExerciseLaterality.bilateral;

    for (final TextEditingController controller in <TextEditingController>[
      _nameFa,
      _nameEn,
      _instructions,
      _safetyNotes,
      _coachNotes,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _nameFa.dispose();
    _nameEn.dispose();
    _instructions.dispose();
    _safetyNotes.dispose();
    _coachNotes.dispose();
    super.dispose();
  }

  void _markDirty() => _dirty = true;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop || _saving || !_dirty) {
          return;
        }
        final bool discard = await _confirmDiscard();
        if (!discard || !context.mounted) {
          return;
        }
        setState(() => _dirty = false);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'ویرایش حرکت سفارشی' : 'حرکت سفارشی جدید'),
          actions: <Widget>[
            IconButton(
              tooltip: 'ذخیره',
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: <Widget>[
                _FormSection(
                  title: 'شناسه حرکت',
                  subtitle: 'نام واضح و یکتا برای جست‌وجو و برنامه‌ساز',
                  icon: Icons.fitness_center_rounded,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameFa,
                      textInputAction: TextInputAction.next,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'نام فارسی *',
                        prefixIcon: Icon(Icons.translate_rounded),
                      ),
                      validator: (String? value) {
                        final int length = value?.trim().length ?? 0;
                        return length < 2 ? 'نام معتبر وارد کنید.' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameEn,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.next,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        labelText: 'نام انگلیسی',
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormSection(
                  title: 'طبقه‌بندی تمرینی',
                  subtitle: 'فیلترها و منطق انتخاب حرکت در برنامه‌ساز',
                  icon: Icons.category_outlined,
                  children: <Widget>[
                    AppSelectionField<MuscleGroup>(
                      label: 'عضله اصلی',
                      value: _primaryMuscle,
                      leadingIcon: Icons.accessibility_new_rounded,
                      options: _options(
                        MuscleGroup.values,
                        (MuscleGroup item) => item.label,
                      ),
                      onChanged: (MuscleGroup value) {
                        setState(() {
                          _primaryMuscle = value;
                          _secondaryMuscles.remove(value);
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'عضلات فرعی',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: MuscleGroup.values
                          .where((MuscleGroup item) => item != _primaryMuscle)
                          .map(
                            (MuscleGroup item) => FilterChip(
                              label: Text(item.label),
                              selected: _secondaryMuscles.contains(item),
                              onSelected: _saving
                                  ? null
                                  : (bool selected) {
                                      setState(() {
                                        selected
                                            ? _secondaryMuscles.add(item)
                                            : _secondaryMuscles.remove(item);
                                        _dirty = true;
                                      });
                                    },
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 16),
                    AppSelectionField<ExerciseType>(
                      label: 'نوع حرکت',
                      value: _type,
                      leadingIcon: Icons.account_tree_outlined,
                      options: _options(
                        ExerciseType.values,
                        (ExerciseType item) => item.label,
                      ),
                      onChanged: (ExerciseType value) => setState(() {
                        _type = value;
                        _dirty = true;
                      }),
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<ExerciseEquipment>(
                      label: 'وسیله مورد نیاز',
                      value: _equipment,
                      leadingIcon: Icons.handyman_outlined,
                      options: _options(
                        ExerciseEquipment.values,
                        (ExerciseEquipment item) => item.label,
                      ),
                      onChanged: (ExerciseEquipment value) => setState(() {
                        _equipment = value;
                        _dirty = true;
                      }),
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<ExerciseDifficulty>(
                      label: 'سطح دشواری',
                      value: _difficulty,
                      leadingIcon: Icons.signal_cellular_alt_rounded,
                      options: _options(
                        ExerciseDifficulty.values,
                        (ExerciseDifficulty item) => item.label,
                      ),
                      onChanged: (ExerciseDifficulty value) => setState(() {
                        _difficulty = value;
                        _dirty = true;
                      }),
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<MovementPattern>(
                      label: 'الگوی حرکتی',
                      value: _movementPattern,
                      leadingIcon: Icons.route_outlined,
                      options: _options(
                        MovementPattern.values,
                        (MovementPattern item) => item.label,
                      ),
                      onChanged: (MovementPattern value) => setState(() {
                        _movementPattern = value;
                        _dirty = true;
                      }),
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<ExerciseLaterality>(
                      label: 'نحوه اجرای طرفین',
                      value: _laterality,
                      leadingIcon: Icons.compare_arrows_rounded,
                      options: _options(
                        ExerciseLaterality.values,
                        (ExerciseLaterality item) => item.label,
                      ),
                      onChanged: (ExerciseLaterality value) => setState(() {
                        _laterality = value;
                        _dirty = true;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormSection(
                  title: 'راهنمای اجرا',
                  subtitle: 'اطلاعاتی که بعداً به اپ ورزشکار منتقل می‌شود',
                  icon: Icons.menu_book_outlined,
                  children: <Widget>[
                    _LongField(
                      controller: _instructions,
                      label: 'توضیح اجرای حرکت',
                      icon: Icons.format_list_numbered_rounded,
                      maxLength: 2000,
                    ),
                    const SizedBox(height: 12),
                    _LongField(
                      controller: _safetyNotes,
                      label: 'نکات ایمنی',
                      icon: Icons.health_and_safety_outlined,
                      maxLength: 1500,
                    ),
                    const SizedBox(height: 12),
                    _LongField(
                      controller: _coachNotes,
                      label: 'یادداشت خصوصی مربی',
                      icon: Icons.lock_outline_rounded,
                      maxLength: 1500,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'در حال ذخیره…' : 'ذخیره حرکت'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<AppSelectionOption<T>> _options<T>(
    Iterable<T> values,
    String Function(T item) label,
  ) {
    return values
        .map((T item) => AppSelectionOption<T>(value: item, title: label(item)))
        .toList(growable: false);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    final ExerciseInput input = ExerciseInput(
      nameFa: _nameFa.text,
      nameEn: _nameEn.text,
      primaryMuscle: _primaryMuscle,
      secondaryMuscles: _secondaryMuscles,
      type: _type,
      equipment: _equipment,
      difficulty: _difficulty,
      movementPattern: _movementPattern,
      laterality: _laterality,
      instructions: _instructions.text,
      safetyNotes: _safetyNotes.text,
      coachNotes: _coachNotes.text,
    );
    try {
      final Exercise? exercise = widget.exercise;
      if (exercise == null) {
        await widget.controller.create(input);
      } else {
        await widget.controller.updateCustom(exercise, input);
      }
      if (!mounted) {
        return;
      }
      _dirty = false;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_messageFor(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<bool> _confirmDiscard() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('تغییرات ذخیره نشده'),
        content: const Text('از صفحه خارج شوید و تغییرات را کنار بگذارید؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ادامه ویرایش'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _messageFor(Object error) {
    if (error is FormatException) {
      return error.message.toString();
    }
    if (error is StateError) {
      return error.message;
    }
    return 'ذخیره حرکت انجام نشد.';
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LongField extends StatelessWidget {
  const _LongField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 3,
      maxLines: 7,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
