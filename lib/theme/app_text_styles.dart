import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text style helpers for the two typefaces used in the redesign: Archivo
/// for body/UI text and Space Mono for labels, badges and mono accents.
class AppText {
  AppText._();

  static TextStyle archivo({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = Colors.white,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.archivo(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w700,
    Color color = Colors.white,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
