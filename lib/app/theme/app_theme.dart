import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color seed = Color(0xFF16A37A);

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return _base(
      scheme,
    ).copyWith(scaffoldBackgroundColor: const Color(0xFFF6F8F7));
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    // Keep this foundation compatible with both FlutLab Flutter 3.32
    // and newer stable Flutter releases. Component-level styling can be
    // expanded after the supported Flutter baseline is pinned.
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
