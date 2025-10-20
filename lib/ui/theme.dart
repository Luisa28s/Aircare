// file: lib/ui/theme.dart
import 'package:flutter/material.dart';

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2BB6C4), // turquesa fresco
  brightness: Brightness.light,
);

ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
