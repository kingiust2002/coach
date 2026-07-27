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
    ).copyWith(scaffoldBackgroundColor: const Color(0xFFF5F7F6));
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: false),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
