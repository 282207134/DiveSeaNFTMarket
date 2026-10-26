import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF2F2F2);
  static const ink = Color(0xFF23262F);
  static const black = Color(0xFF141416);
  static const muted = Color(0xFF8A8A8F);
  static const line = Color(0xFFE6E8EC);
  static const blue = Color(0xFF0780FF);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.ink,
    primary: AppColors.black,
    surface: AppColors.background,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFAFAFB),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'DMSans',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(20),
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFB1B1B5)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.black, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  dividerColor: AppColors.line,
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.ink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
