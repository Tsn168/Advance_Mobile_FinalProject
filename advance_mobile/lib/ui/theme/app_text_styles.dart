import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings
  static final TextStyle h1 = GoogleFonts.sora(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
  );

  static final TextStyle h2 = GoogleFonts.sora(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
  );

  static final TextStyle h3 = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static final TextStyle h4 = GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final TextStyle h5 = GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get heading4 => h4;

  // Body
  static final TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.45,
  );

  static final TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.45,
  );

  static final TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Button
  static final TextStyle buttonText = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // Label
  static final TextStyle label = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static final TextStyle labelSmall = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static final TextStyle labelMedium = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static final TextStyle labelLarge = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Caption
  static final TextStyle caption = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}
