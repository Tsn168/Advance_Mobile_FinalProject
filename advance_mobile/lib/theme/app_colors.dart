import 'package:flutter/material.dart';

/// App Colors - All color constants used throughout the app
/// No hard-coded colors in widgets - everything references this file
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B83FF);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFFF5252);
  static const Color secondaryLight = Color(0xFFFF9999);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Status Colors
  static const Color success = Color(0xFF00C851);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFFF4444);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);

  // Divider & Border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);

  // Specific Feature Colors
  static const Color availableBike = Color(0xFF00C851);
  static const Color bookedBike = Color(0xFFFF6B6B);
  static const Color maintenanceBike = Color(0xFFFFC107);
  static const Color stationMarker = Color(0xFF6C63FF);
  static const Color selectedStation = Color(0xFF00C851);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
  );
}
