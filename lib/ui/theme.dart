import 'package:flutter/material.dart';

// Art Bible palette (locked)
class SiegeTheme {
  // Core palette
  static const Color background = Color(0xFF0B1020); // Night base
  static const Color panel = Color(0xFF1A2338); // Mid stone
  static const Color panel2 = Color(0xFF12151b); // Darker variant
  static const Color ink = Color(0xFFe9e6df); // Light text (keeping existing)
  static const Color muted = Color(0xFF8A9BB0); // Muted steel
  static const Color line = Color(0xFF2c3543); // Keeping existing line color

  // Force colors (warm/cool)
  static const Color attacker = Color(0xFFE8A04A); // Attacker amber
  static const Color attackerDim = Color(0xFFC45C26); // Attacker ember
  static const Color attackerGold = Color(0xFFF0D9A8); // Soft gold UI
  
  static const Color defender = Color(0xFF2A6B6B); // Defender teal
  static const Color defenderDim = Color(0xFF1a4545); // Darker teal
  static const Color defenderLight = Color(0xFF7EC8C8); // Ice highlight

  // Status colors
  static const Color danger = Color(0xFFFF6B2C); // Fire only
  static const Color good = Color(0xFF7cb87f); // Keeping existing
  static const Color gold = Color(0xFFF0D9A8); // Soft gold

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
