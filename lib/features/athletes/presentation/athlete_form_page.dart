import 'package:flutter/material.dart';

import '../domain/athlete.dart';
import 'athletes_controller.dart';

class AthleteFormPage extends StatefulWidget {
  const AthleteFormPage({
    required this.controller,
    this.athlete,
    super.key,
  });

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
  late final TextEditingController _injuries;
  late final TextEditingController _notes;
  late TrainingLevel _level;
  bool _saving = false;

  bool get _isEditing => widget.athlete != null;

  @override
  void initState() {
    super.initState();
    final Athlete? athlete = widget.athlete;
    _name = TextEditingController(text: athlete?.fullName ?? '');
    _phone = TextEditingController(text: athlete?.phone ?? '');
    _goal = TextEditingController(text: athlete?.goal ?? '');
    _injuries = TextEditingController(text: athlete?.injuries ?? '');
    _notes = TextEditingController(text: athlete?.notes ?? '');
    _level = athlete?.trainingLevel ?? TrainingLevel.beginner;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _goal.dispose();
    _injuries.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'ویرایش شاگرد' : 'شاگرد جدید')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (String? value) {
                if (value == null || value.trim().length < 2) {
                  return 'نام معتبر وارد کنید.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'شماره تماس',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TrainingLevel>(
              value: _level,
              decoration: const InputDecoration(
                labelText: 'سطح تمرینی',
                prefixIcon: Icon(Icons.signal_cellular_alt),
              ),
              items: TrainingLevel.values
                  .map(
                    (TrainingLevel level) => DropdownMenuItem<TrainingLevel>(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (TrainingLevel? value) {
                if (value != null) {
                  setState(() => _level = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _goal,
              decoration: const InputDecoration(
                labelText: 'هدف تمرینی',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _injuries,
              decoration: const InputDecoration(
                labelText: 'آسیب‌ها و محدودیت‌ها',
                prefixIcon: Icon(Icons.health_and_safety_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'یادداشت مربی',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              maxLines: 4,
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
              label: Text(_isEditing ? 'ذخیره تغییرات' : 'ثبت شاگرد'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);
    try {
      final Athlete? existing = widget.athlete;
      if (existing == null) {
        await widget.controller.create(
          fullName: _name.text,
          phone: _phone.text,
          goal: _goal.text,
          trainingLevel: _level,
          injuries: _injuries.text,
          notes: _notes.text,
        );
      } else {
        await widget.controller.update(
          existing.copyWith(
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            goal: _goal.text.trim(),
            trainingLevel: _level,
            injuries: _injuries.text.trim(),
            notes: _notes.text.trim(),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
