import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppSelectionOption<T> {
  const AppSelectionOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
}

class AppSelectionField<T> extends StatelessWidget {
  const AppSelectionField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.leadingIcon,
    this.helperText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final T value;
  final List<AppSelectionOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? leadingIcon;
  final String? helperText;
  final bool enabled;

  AppSelectionOption<T> get _selected {
    return options.firstWhere(
      (AppSelectionOption<T> item) => item.value == value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppSelectionOption<T> selected = _selected;

    return Semantics(
      button: true,
      enabled: enabled,
      label: '$label، ${selected.title}',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? () => _open(context) : null,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: enabled
                ? colors.surfaceContainerHighest.withOpacity(0.48)
                : colors.surfaceContainerHighest.withOpacity(0.24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(leadingIcon, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selected.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (helperText != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        helperText!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final T? selected = await showAppSelectionSheet<T>(
      context: context,
      title: label,
      value: value,
      options: options,
    );
    if (selected != null && selected != value) {
      onChanged(selected);
    }
  }
}

Future<T?> showAppSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required T value,
  required List<AppSelectionOption<T>> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) =>
        _SelectionSheet<T>(title: title, value: value, options: options),
  );
}

class _SelectionSheet<T> extends StatefulWidget {
  const _SelectionSheet({
    required this.title,
    required this.value,
    required this.options,
  });

  final String title;
  final T value;
  final List<AppSelectionOption<T>> options;

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double height = math.min(
      MediaQuery.sizeOf(context).height * 0.82,
      210 + (widget.options.length * 76.0),
    );
    final String normalizedQuery = _query.trim().toLowerCase();
    final List<AppSelectionOption<T>> visible = widget.options
        .where(
          (AppSelectionOption<T> item) =>
              normalizedQuery.isEmpty ||
              item.title.toLowerCase().contains(normalizedQuery) ||
              (item.subtitle?.toLowerCase().contains(normalizedQuery) ?? false),
        )
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'بستن',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              if (widget.options.length > 7)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: TextField(
                    autofocus: false,
                    onChanged: (String value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'جست‌وجو در گزینه‌ها',
                    ),
                  ),
                ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('گزینه‌ای پیدا نشد'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int index) {
                          final AppSelectionOption<T> option = visible[index];
                          final bool selected = option.value == widget.value;
                          return _SelectionTile<T>(
                            option: option,
                            selected: selected,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile<T> extends StatelessWidget {
  const _SelectionTile({required this.option, required this.selected});

  final AppSelectionOption<T> option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).pop(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            if (option.icon != null) ...<Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withOpacity(0.12)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  option.icon,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (option.subtitle != null) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      option.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: selected
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey<String>('selected'),
                      color: colors.primary,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: const ValueKey<String>('not-selected'),
                      color: colors.outline,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
