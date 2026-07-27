from pathlib import Path


for path in Path("lib").rglob("*.dart"):
    text = path.read_text(encoding="utf-8")
    updated = text.replace(".withOpacity(", ".withValues(alpha: ")
    path.write_text(updated, encoding="utf-8")

exercise_form = Path(
    "lib/features/exercises/presentation/exercise_form_page.dart"
)
text = exercise_form.read_text(encoding="utf-8")
old = """        final bool discard = await _confirmDiscard();
        if (discard && mounted) {
          setState(() => _dirty = false);
          Navigator.of(context).pop();
        }"""
new = """        final bool discard = await _confirmDiscard();
        if (!discard || !context.mounted) {
          return;
        }
        setState(() => _dirty = false);
        Navigator.of(context).pop();"""
if old not in text:
    raise SystemExit("Exercise PopScope pattern was not found.")
exercise_form.write_text(text.replace(old, new, 1), encoding="utf-8")

athlete_form = Path(
    "lib/features/athletes/presentation/athlete_form_page.dart"
)
text = athlete_form.read_text(encoding="utf-8")
old = """    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: Scaffold("""
new = """    return PopScope<Object?>(
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
      child: Scaffold("""
if old not in text:
    raise SystemExit("Athlete WillPopScope pattern was not found.")
athlete_form.write_text(text.replace(old, new, 1), encoding="utf-8")
