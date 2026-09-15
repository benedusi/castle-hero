import 'package:flutter/material.dart';

class SiegeTheme {
  static const Color background = Color(0xFF12151b);
  static const Color panel = Color(0xFF1b2028);
  static const Color panel2 = Color(0xFF232b36);
  static const Color ink = Color(0xFFe9e6df);
  static const Color muted = Color(0xFF8b94a1);
  static const Color line = Color(0xFF2c3543);

  static const Color attacker = Color(0xFFef8b4a);
  static const Color attackerDim = Color(0xFF7a4e30);
  static const Color defender = Color(0xFF6fa6c9);
  static const Color defenderDim = Color(0xFF3a566a);

  static const Color danger = Color(0xFFe0554d);
  static const Color good = Color(0xFF7cb87f);
  static const Color gold = Color(0xFFe6b653);

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: attacker,
          secondary: defender,
          surface: panel,
          error: danger,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.56,
            color: ink,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.38,
            color: ink,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: ink,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: muted,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.52,
            color: muted,
          ),
        ),
        cardTheme: const CardThemeData(
          color: panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(11)),
            side: BorderSide(color: line, width: 1),
          ),
        ),
      );
}
