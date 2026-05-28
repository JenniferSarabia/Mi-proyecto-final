// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Paleta azul Urba & Flow (igual al proyecto Django)
  static const primary = Color(0xFF003366); // azul marino oscuro
  static const primaryLight = Color(0xFF1565C0); // azul medio
  static const accent = Color(0xFF1E88E5); // azul brillante
  static const accentLight = Color(0xFF42A5F5); // azul claro
  static const surface = Color(0xFFE3F2FD); // fondo azul muy suave
  static const background = Color(0xFFF0F4F8); // fondo gris azulado
  static const onPrimary = Colors.white;
  static const danger = Color(0xFFC0392B);
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF39C12);
  static const textDark = Color(0xFF1A1A2E);
  static const textMuted = Color(0xFF5A6A7A);
  static const cardBorder = Color(0xFFBBD6F0);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        textTheme: GoogleFonts.ralewayTextTheme().copyWith(
          displayLarge: GoogleFonts.raleway(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
          headlineMedium: GoogleFonts.raleway(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          titleLarge: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          bodyLarge: GoogleFonts.raleway(
            fontSize: 15,
            color: AppColors.textDark,
          ),
          bodyMedium: GoogleFonts.raleway(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                GoogleFonts.raleway(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                GoogleFonts.raleway(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textMuted),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        scaffoldBackgroundColor: AppColors.background,
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: AppColors.primary,
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Color(0xFF90CAF9)),
          selectedLabelTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          unselectedLabelTextStyle: TextStyle(color: Color(0xFF90CAF9)),
        ),
      );
}
