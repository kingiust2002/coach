import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/utils/input_normalizer.dart';
import '../../../core/utils/persian_date.dart';
import '../../../shared/widgets/app_selection_field.dart';
import '../domain/athlete.dart';
import 'athletes_controller.dart';

class AthleteFormPage extends StatefulWidget {
  const AthleteFormPage({required this.controller, this.athlete, super.key});

  final AthletesController controller;
  final Athlete? athlete;

  @override
  State<AthleteFormPage> createState() => _AthleteFormPageState();
}

class _AthleteFormPageState extends State<AthleteFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _goal;
  late final TextEditingController _experience;
  late final TextEditingController _injuries;
  late final TextEditingController _medicalNotes;
  late final TextEditingController _notes;
  late TrainingLevel _level;
  late AthleteGoal _primaryGoal;
  late TrainingEnvironment _environment;
  late int _daysPerWeek;
  late int _sessionMinutes;
  DateTime? _birthDate;
  bool _saving = false;
  bool _dirty = false;

  bool get _isEditing => widget.athlete != null;

  @override
  void initState() {
    super.initState();
    final Athlete? athlete = widget.athlete;
    _name = TextEditingController(text: athlete?.fullName ?? '');
    _phone = TextEditingController(text: athlete?.phone ?? '');
    _goal = TextEditingController(text: athlete?.goal ?? '');
    _experience = TextEditingController(
      text: (athlete?.experienceMonths ?? 0).toString(),
    );
    _injuries = TextEditingController(text: athlete?.injuries ?? '');
    _medicalNotes = TextEditingController(text: athlete?.medicalNotes ?? '');
    _notes = TextEditingController(text: athlete?.notes ?? '');
    _level = athlete?.trainingLevel ?? TrainingLevel.beginner;
    _primaryGoal = athlete?.primaryGoal ?? AthleteGoal.generalFitness;
    _environment = athlete?.trainingEnvironment ?? TrainingEnvironment.gym;
    _daysPerWeek = athlete?.preferredDaysPerWeek ?? 3;
    _sessionMinutes = athlete?.preferredSessionMinutes ?? 60;
    _birthDate = athlete?.birthDate;

    for (final TextEditingController controller in <TextEditingController>[
      _name,
      _phone,
      _goal,
      _experience,
      _injuries,
      _medicalNotes,
      _notes,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _goal.dispose();
    _experience.dispose();
    _injuries.dispose();
    _medicalNotes.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      _dirty = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_dirty,
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
          title: Text(_isEditing ? 'ویرایش پرونده شاگرد' : 'پرونده شاگرد جدید'),
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
                if (widget.athlete?.isActive == false) ...<Widget>[
                  const _ArchivedBanner(),
                  const SizedBox(height: 16),
                ],
                _FormSection(
                  title: 'اطلاعات پایه',
                  subtitle: 'اطلاعات لازم برای شناسایی و ارتباط با شاگرد',
                  icon: Icons.badge_outlined,
                  children: <Widget>[
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const <String>[AutofillHints.name],
                      maxLength: 80,
                      decoration: const InputDecoration(
                        labelText: 'نام و نام خانوادگی *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (String? value) {
                        final int length = InputNormalizer.singleLine(
                          value ?? '',
                        ).length;
                        if (length < 2) {
                          return 'نام معتبر وارد کنید.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      autofillHints: const <String>[
                        AutofillHints.telephoneNumber,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'شماره تماس',
                        prefixIcon: Icon(Icons.phone_outlined),
                        helperText: 'اختیاری؛ ارقام فارسی نیز پذیرفته می‌شوند.',
                      ),
                      validator: (String? value) {
                        final String phone = InputNormalizer.phone(value ?? '');
                        final int length = phone.replaceFirst('+', '').length;
                        if (length != 0 && (length < 7 || length > 15)) {
                          return 'شماره تماس معتبر نیست.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _DateSelectionField(
                      value: _birthDate,
                      onTap: _saving ? null : _pickBirthDate,
                      onClear: _saving || _birthDate == null
                          ? null
                          : () {
                              setState(() {
                                _birthDate = null;
                                _dirty = true;
                              });
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormSection(
                  title: 'هدف و سابقه تمرینی',
                  subtitle: 'مبنای تصمیم‌گیری برای برنامه‌ریزی و انتخاب حرکات',
                  icon: Icons.track_changes_rounded,
                  children: <Widget>[
                    AppSelectionField<AthleteGoal>(
                      label: 'هدف اصلی',
                      value: _primaryGoal,
                      leadingIcon: Icons.flag_outlined,
                      helperText: _primaryGoal.description,
                      options: AthleteGoal.values
                          .map(
                            (AthleteGoal goal) =>
                                AppSelectionOption<AthleteGoal>(
                                  value: goal,
                                  title: goal.label,
                                  subtitle: goal.description,
                                  icon: _goalIcon(goal),
                                ),
                          )
                          .toList(growable: false),
                      onChanged: (AthleteGoal value) {
                        setState(() {
                          _primaryGoal = value;
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _goal,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'توضیح اختصاصی هدف',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.edit_note_rounded),
                        helperText:
                            'انتظار شاگرد، اولویت‌ها و معیار موفقیت را بنویسید.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<TrainingLevel>(
                      label: 'سطح تمرینی',
                      value: _level,
                      leadingIcon: Icons.signal_cellular_alt_rounded,
                      helperText: _level.description,
                      options: TrainingLevel.values
                          .map(
                            (TrainingLevel level) =>
                                AppSelectionOption<TrainingLevel>(
                                  value: level,
                                  title: level.label,
                                  subtitle: level.description,
                                  icon: Icons.bar_chart_rounded,
                                ),
                          )
                          .toList(growable: false),
                      onChanged: (TrainingLevel value) {
                        setState(() {
                          _level = value;
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _experience,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'سابقه تمرین منظم (ماه)',
                        prefixIcon: Icon(Icons.history_rounded),
                        helperText: 'از صفر تا ۷۲۰ ماه',
                      ),
                      validator: (String? value) {
                        final int? months = InputNormalizer.integer(
                          value ?? '',
                        );
                        if (months == null || months < 0 || months > 720) {
                          return 'عدد معتبر بین صفر تا ۷۲۰ وارد کنید.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormSection(
                  title: 'ترجیحات برنامه',
                  subtitle:
                      'محدودیت زمانی و محیطی برای ساخت برنامه واقع‌بینانه',
                  icon: Icons.tune_rounded,
                  children: <Widget>[
                    AppSelectionField<int>(
                      label: 'تعداد روز تمرین در هفته',
                      value: _daysPerWeek,
                      leadingIcon: Icons.calendar_view_week_rounded,
                      helperText:
                          'بر اساس برنامه واقعی زندگی شاگرد انتخاب شود.',
                      options: List<AppSelectionOption<int>>.generate(7, (
                        int index,
                      ) {
                        final int value = index + 1;
                        return AppSelectionOption<int>(
                          value: value,
                          title: '$value روز در هفته',
                          subtitle: value <= 2
                              ? 'حجم کمتر و تمرکز بیشتر در هر جلسه'
                              : value <= 4
                              ? 'تعادل مناسب برای بیشتر اهداف'
                              : 'تقسیم حجم تمرین در جلسات بیشتر',
                          icon: Icons.event_available_rounded,
                        );
                      }),
                      onChanged: (int value) {
                        setState(() {
                          _daysPerWeek = value;
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<int>(
                      label: 'مدت ترجیحی هر جلسه',
                      value: _sessionMinutes,
                      leadingIcon: Icons.timer_outlined,
                      helperText:
                          'زمان گرم‌کردن و سردکردن نیز در نظر گرفته شود.',
                      options: const <AppSelectionOption<int>>[
                        AppSelectionOption<int>(
                          value: 30,
                          title: '۳۰ دقیقه',
                          subtitle: 'جلسه کوتاه و فشرده',
                          icon: Icons.bolt_rounded,
                        ),
                        AppSelectionOption<int>(
                          value: 45,
                          title: '۴۵ دقیقه',
                          subtitle: 'مناسب برنامه‌های کم‌حجم یا پرتراکم',
                          icon: Icons.timer_rounded,
                        ),
                        AppSelectionOption<int>(
                          value: 60,
                          title: '۶۰ دقیقه',
                          subtitle: 'زمان استاندارد برای بیشتر برنامه‌ها',
                          icon: Icons.schedule_rounded,
                        ),
                        AppSelectionOption<int>(
                          value: 75,
                          title: '۷۵ دقیقه',
                          subtitle: 'فضای بیشتر برای حجم و استراحت',
                          icon: Icons.more_time_rounded,
                        ),
                        AppSelectionOption<int>(
                          value: 90,
                          title: '۹۰ دقیقه',
                          subtitle: 'جلسه کامل با حجم بالاتر',
                          icon: Icons.hourglass_bottom_rounded,
                        ),
                        AppSelectionOption<int>(
                          value: 120,
                          title: '۱۲۰ دقیقه',
                          subtitle:
                              'فقط برای برنامه‌های خاص و ورزشکاران باتجربه',
                          icon: Icons.timelapse_rounded,
                        ),
                      ],
                      onChanged: (int value) {
                        setState(() {
                          _sessionMinutes = value;
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    AppSelectionField<TrainingEnvironment>(
                      label: 'محیط اصلی تمرین',
                      value: _environment,
                      leadingIcon: Icons.location_on_outlined,
                      helperText: _environment.description,
                      options: TrainingEnvironment.values
                          .map(
                            (TrainingEnvironment environment) =>
                                AppSelectionOption<TrainingEnvironment>(
                                  value: environment,
                                  title: environment.label,
                                  subtitle: environment.description,
                                  icon: _environmentIcon(environment),
                                ),
                          )
                          .toList(growable: false),
                      onChanged: (TrainingEnvironment value) {
                        setState(() {
                          _environment = value;
                          _dirty = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FormSection(
                  title: 'سلامت و یادداشت‌ها',
                  subtitle:
                      'این اطلاعات جایگزین ارزیابی یا تشخیص متخصص درمان نیست.',
                  icon: Icons.health_and_safety_outlined,
                  children: <Widget>[
                    TextFormField(
                      controller: _injuries,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                      maxLength: 800,
                      decoration: const InputDecoration(
                        labelText: 'آسیب‌ها و محدودیت‌های حرکتی',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.personal_injury_outlined),
                        helperText:
                            'ناحیه، حرکت حساس و محدودیت اعلام‌شده را ثبت کنید.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _medicalNotes,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                      maxLength: 800,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات پزشکی اعلام‌شده',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.medical_information_outlined),
                        helperText:
                            'فقط اطلاعات لازم برای ایمنی تمرین ثبت شود.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notes,
                      textInputAction: TextInputAction.done,
                      maxLines: 4,
                      maxLength: 1200,
                      decoration: const InputDecoration(
                        labelText: 'یادداشت خصوصی مربی',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                      onFieldSubmitted: (_) {
                        if (!_saving) {
                          _save();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isEditing ? 'ذخیره پرونده' : 'ثبت پرونده شاگرد'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final Jalali today = Jalali.now();
    final Jalali initial = _birthDate == null
        ? Jalali(today.year - 25, today.month, today.day)
        : PersianDate.toJalali(_birthDate!);
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: Jalali(1309, 1, 1),
      lastDate: today,
      helpText: 'تاریخ تولد شاگرد',
      cancelText: 'انصراف',
      confirmText: 'انتخاب',
      initialDatePickerMode: PersianDatePickerMode.year,
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate = PersianDate.toUtcDate(picked);
        _dirty = true;
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty || _saving) {
      return true;
    }
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('خروج بدون ذخیره؟'),
        content: const Text('تغییرات این فرم هنوز ذخیره نشده‌اند.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ادامه ویرایش'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('خروج بدون ذخیره'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);

    final AthleteProfileInput input = AthleteProfileInput(
      fullName: _name.text,
      phone: _phone.text,
      birthDate: _birthDate,
      primaryGoal: _primaryGoal,
      goal: _goal.text,
      trainingLevel: _level,
      experienceMonths: InputNormalizer.integer(_experience.text) ?? 0,
      preferredDaysPerWeek: _daysPerWeek,
      preferredSessionMinutes: _sessionMinutes,
      trainingEnvironment: _environment,
      injuries: _injuries.text,
      medicalNotes: _medicalNotes.text,
      notes: _notes.text,
    );

    try {
      final Athlete? existing = widget.athlete;
      if (existing == null) {
        await widget.controller.create(input);
      } else {
        await widget.controller.updateProfile(existing, input);
      }
      _dirty = false;
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _errorMessage(Object error) {
    if (error is FormatException) {
      return error.message.toString();
    }
    return 'ذخیره پرونده انجام نشد. دوباره تلاش کنید.';
  }

  IconData _goalIcon(AthleteGoal goal) {
    switch (goal) {
      case AthleteGoal.generalFitness:
        return Icons.favorite_outline_rounded;
      case AthleteGoal.muscleGain:
        return Icons.fitness_center_rounded;
      case AthleteGoal.fatLoss:
        return Icons.monitor_weight_outlined;
      case AthleteGoal.strength:
        return Icons.sports_martial_arts_outlined;
      case AthleteGoal.endurance:
        return Icons.directions_run_rounded;
      case AthleteGoal.mobility:
        return Icons.accessibility_new_rounded;
      case AthleteGoal.rehabilitation:
        return Icons.healing_rounded;
      case AthleteGoal.sportPerformance:
        return Icons.emoji_events_outlined;
      case AthleteGoal.other:
        return Icons.more_horiz_rounded;
    }
  }

  IconData _environmentIcon(TrainingEnvironment environment) {
    switch (environment) {
      case TrainingEnvironment.gym:
        return Icons.fitness_center_rounded;
      case TrainingEnvironment.home:
        return Icons.home_outlined;
      case TrainingEnvironment.outdoor:
        return Icons.park_outlined;
      case TrainingEnvironment.mixed:
        return Icons.alt_route_rounded;
    }
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DateSelectionField extends StatelessWidget {
  const _DateSelectionField({
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? value;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String label = PersianDate.format(value);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.cake_outlined,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'تاریخ تولد',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                tooltip: 'پاک‌کردن تاریخ تولد',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              )
            else
              Icon(Icons.calendar_month_outlined, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _ArchivedBanner extends StatelessWidget {
  const _ArchivedBanner();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.inventory_2_outlined, color: colors.onSecondaryContainer),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'این شاگرد بایگانی شده است. ویرایش اطلاعات همچنان امکان‌پذیر است.',
            ),
          ),
        ],
      ),
    );
  }
}
