import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SparkColors {
  static const blueDeep = Color(0xFF1B7FD6);
  static const blueMid = Color(0xFF4DB6FF);
  static const blueSoft = Color(0xFFB8E4FF);
  static const blueSky = Color(0xFFE8F7FF);

  static const pinkDeep = Color(0xFFE84B8A);
  static const pinkMid = Color(0xFFFF8AB8);
  static const pinkSoft = Color(0xFFFFD3E4);
  static const pinkSky = Color(0xFFFFF0F6);

  static const cream = Color(0xFFFFF9F2);
  static const ink = Color(0xFF2A2430);
  static const muted = Color(0xFF6B6172);
}

ThemeData buildSparkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SparkColors.blueMid,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: SparkColors.cream,
  );

  return base.copyWith(
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: SparkColors.ink,
      displayColor: SparkColors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: SparkColors.ink,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 2,
    ),
  );
}
