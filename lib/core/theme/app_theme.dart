import 'package:flutter/material.dart';
import 'theme.dart';
import 'util.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(BuildContext context) {
    final textTheme = createTextTheme(context, 'DM Sans', 'Fraunces');
    final material = MaterialTheme(textTheme);
    return material.light().copyWith(
      inputDecorationTheme: _inputTheme(MaterialTheme.lightScheme()),
      elevatedButtonTheme: _buttonTheme(MaterialTheme.lightScheme()),
    );
  }

  static ThemeData dark(BuildContext context) {
    final textTheme = createTextTheme(context, 'DM Sans', 'Fraunces');
    final material = MaterialTheme(textTheme);
    return material.dark().copyWith(
      inputDecorationTheme: _inputTheme(MaterialTheme.darkScheme()),
      elevatedButtonTheme: _buttonTheme(MaterialTheme.darkScheme()),
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ElevatedButtonThemeData _buttonTheme(ColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.onPrimaryContainer,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}