import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme customTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.baloo2(),
    displayMedium: GoogleFonts.baloo2(),
    displaySmall: GoogleFonts.baloo2(),
    headlineLarge: GoogleFonts.baloo2(),
    headlineMedium: GoogleFonts.baloo2(),
    headlineSmall: GoogleFonts.baloo2(
      fontSize: 20,
    ),
    titleLarge: GoogleFonts.zenDots(),
    titleMedium: GoogleFonts.zenDots(),
    titleSmall: GoogleFonts.zenDots(
      fontSize: 18,
    ),
    bodyLarge: GoogleFonts.baloo2(),
    bodyMedium: GoogleFonts.baloo2(
      fontSize: 18,
    ),
    bodySmall: GoogleFonts.baloo2(),
  );
}
