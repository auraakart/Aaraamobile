import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundBase : Colors.black,
      primaryColor: AppColors.brandPrimary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.brandPrimary,
        secondary: AppColors.brandSecondary,
        surface: AppColors.backgroundSurface,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        error: Colors.red,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData().copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSurface,
        border: _outlineBorder(AppColors.borderDefault),
        enabledBorder: _outlineBorder(AppColors.borderDefault),
        focusedBorder: _outlineBorder(AppColors.brandPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.brandPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _outlineBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color),
      );
}

Color setColorBasedOnTheme(
    {required BuildContext context,
    required Color lightColor,
    required Color darkColor}) {
  final Brightness brightness = Theme.of(context).brightness;
  return brightness == Brightness.light ? lightColor : darkColor;
}


