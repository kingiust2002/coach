from pathlib import Path


def replace(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding="utf-8")
    if old not in text:
        raise RuntimeError(f"Expected snippet not found in {path}: {old[:120]!r}")
    file.write_text(text.replace(old, new, 1), encoding="utf-8")


replace(
    "lib/core/database/database_schema.dart",
    "static const int version = 3;",
    "static const int version = 4;",
)

replace(
    "lib/features/exercises/presentation/exercises_page.dart",
    "import 'exercise_detail_page.dart';\nimport 'exercise_form_page.dart';",
    "import 'exercise_detail_page.dart';\nimport 'exercise_form_page.dart';\nimport 'exercise_media_controller.dart';",
)
replace(
    "lib/features/exercises/presentation/exercises_page.dart",
    "class ExercisesPage extends StatefulWidget {\n  const ExercisesPage({required this.controller, super.key});\n\n  final ExercisesController controller;",
    "class ExercisesPage extends StatefulWidget {\n  const ExercisesPage({\n    required this.controller,\n    required this.mediaController,\n    super.key,\n  });\n\n  final ExercisesController controller;\n  final ExerciseMediaController mediaController;",
)
replace(
    "lib/features/exercises/presentation/exercises_page.dart",
    "return AnimatedBuilder(\n      animation: widget.controller,",
    "return AnimatedBuilder(\n      animation: Listenable.merge(<Listenable>[\n        widget.controller,\n        widget.mediaController,\n      ]),",
)
replace(
    "lib/features/exercises/presentation/exercises_page.dart",
    "actions: <Widget>[\n              IconButton(\n                tooltip: 'بازخوانی',",
    "actions: <Widget>[\n              IconButton(\n                tooltip: 'همگام‌سازی کتابخانه آنلاین',\n                onPressed:\n                    widget.mediaController.isSyncing ||\n                        !widget.mediaController.canSync\n                    ? null\n                    : _syncOnlineCatalog,\n                icon: widget.mediaController.isSyncing\n                    ? const SizedBox.square(\n                        dimension: 20,\n                        child: CircularProgressIndicator(strokeWidth: 2),\n                      )\n                    : const Icon(Icons.cloud_sync_outlined),\n              ),\n              IconButton(\n                tooltip: 'بازخوانی',",
)
replace(
    "lib/features/exercises/presentation/exercises_page.dart",
    "controller: widget.controller,\n                ),",
    "controller: widget.controller,\n                  mediaController: widget.mediaController,\n                ),",
)
replace(
    "lib/features/exercises/presentation/exercises_page.dart",
    "  Future<void> _createExercise() async {",
    "  Future<void> _syncOnlineCatalog() async {\n    try {\n      final int count = await widget.mediaController.syncCatalog();\n      await widget.controller.load();\n      if (mounted) {\n        ScaffoldMessenger.of(context).showSnackBar(\n          SnackBar(content: Text('$count حرکت از کتابخانه آنلاین به‌روز شد.')),\n        );\n      }\n    } catch (error) {\n      if (mounted) {\n        ScaffoldMessenger.of(context).showSnackBar(\n          SnackBar(content: Text(error.toString())),\n        );\n      }\n    }\n  }\n\n  Future<void> _createExercise() async {",
)

replace(
    "lib/features/exercises/presentation/exercise_detail_page.dart",
    "import 'exercise_form_page.dart';\nimport 'exercises_controller.dart';",
    "import 'exercise_form_page.dart';\nimport 'exercise_media_card.dart';\nimport 'exercise_media_controller.dart';\nimport 'exercises_controller.dart';",
)
replace(
    "lib/features/exercises/presentation/exercise_detail_page.dart",
    "required this.controller,\n    super.key,",
    "required this.controller,\n    required this.mediaController,\n    super.key,",
)
replace(
    "lib/features/exercises/presentation/exercise_detail_page.dart",
    "final ExercisesController controller;",
    "final ExercisesController controller;\n  final ExerciseMediaController mediaController;",
)
replace(
    "lib/features/exercises/presentation/exercise_detail_page.dart",
    "_Header(exercise: exercise),\n              const SizedBox(height: 16),\n              _InfoSection(",
    "_Header(exercise: exercise),\n              const SizedBox(height: 16),\n              ExerciseMediaCard(\n                exercise: exercise,\n                controller: mediaController,\n              ),\n              const SizedBox(height: 16),\n              _InfoSection(",
)

replace(
    "lib/features/athletes/presentation/athlete_form_page.dart",
    "import 'package:flutter/material.dart';",
    "import 'package:flutter/material.dart';\nimport 'package:persian_datetime_picker/persian_datetime_picker.dart';",
)
replace(
    "lib/features/athletes/presentation/athlete_form_page.dart",
    "import '../../../core/utils/input_normalizer.dart';",
    "import '../../../core/utils/input_normalizer.dart';\nimport '../../../core/utils/persian_date.dart';",
)
replace(
    "lib/features/athletes/presentation/athlete_form_page.dart",
    "  Future<void> _pickBirthDate() async {\n    final DateTime today = DateTime.now();\n    final DateTime? picked = await showDatePicker(\n      context: context,\n      initialDate: _birthDate?.toLocal() ?? DateTime(today.year - 25),\n      firstDate: DateTime(1930),\n      lastDate: today,\n      helpText: 'تاریخ تولد شاگرد',\n      cancelText: 'انصراف',\n      confirmText: 'انتخاب',\n    );\n    if (picked != null && mounted) {\n      setState(() {\n        _birthDate = DateTime.utc(picked.year, picked.month, picked.day);\n        _dirty = true;\n      });\n    }\n  }",
    "  Future<void> _pickBirthDate() async {\n    final Jalali today = Jalali.now();\n    final Jalali initial = _birthDate == null\n        ? Jalali(today.year - 25, today.month, today.day)\n        : PersianDate.toJalali(_birthDate!);\n    final Jalali? picked = await showPersianDatePicker(\n      context: context,\n      initialDate: initial,\n      firstDate: Jalali(1309, 1, 1),\n      lastDate: today,\n      helpText: 'تاریخ تولد شاگرد',\n      cancelText: 'انصراف',\n      confirmText: 'انتخاب',\n      initialDatePickerMode: PersianDatePickerMode.year,\n    );\n    if (picked != null && mounted) {\n      setState(() {\n        _birthDate = PersianDate.toUtcDate(picked);\n        _dirty = true;\n      });\n    }\n  }",
)
replace(
    "lib/features/athletes/presentation/athlete_form_page.dart",
    "    final DateTime? date = value?.toLocal();\n    final String label = date == null\n        ? 'ثبت نشده'\n        : '${date.year.toString().padLeft(4, '0')}/'\n              '${date.month.toString().padLeft(2, '0')}/'\n              '${date.day.toString().padLeft(2, '0')}';",
    "    final String label = PersianDate.format(value);",
)

print("Exercise media and Persian calendar patches applied.")
