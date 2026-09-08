import 'package:flutter/material.dart';

class AppColors {
  static const azul = Color(0xFF17365D);
  static const fondo = Color(0xFFF4F7FB);
  static const blanco = Color(0xFFFFFFFF);
  static const texto = Color(0xFF1F2937);
  static const gris = Color(0xFF6B7280);
  static const borde = Color(0xFFD8E0EA);
  static const verde = Color(0xFF15803D);
  static const rojo = Color(0xFFB91C1C);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.azul,
    surface: AppColors.blanco,
    error: AppColors.rojo,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.fondo,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.azul,
      foregroundColor: AppColors.blanco,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.blanco,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borde),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.azul,
        foregroundColor: AppColors.blanco,
        minimumSize: const Size(220, 52),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.texto, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: AppColors.gris),
      bodyLarge: TextStyle(color: AppColors.texto),
    ),
  );
}
