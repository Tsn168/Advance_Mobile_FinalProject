import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFF2DD4BF);
  static const Color accent = Color(0xFFF59E0B);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF8FAFC);
  static const Color grey200 = Color(0xFFF1F5F9);
  static const Color grey300 = Color(0xFFE2E8F0);
  static const Color grey400 = Color(0xFFCBD5E1);
  static const Color grey500 = Color(0xFF94A3B8);
  static const Color grey600 = Color(0xFF64748B);
  static const Color grey700 = Color(0xFF475569);
  static const Color grey800 = Color(0xFF334155);
  static const Color grey900 = Color(0xFF1E293B);

  // Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // Semantic
  static const Color disabled = grey400;
  static const Color divider = Color(0xFFD7E6E3);
  static const Color background = Color(0xFFF4F8F7);
  static const Color surface = white;
  static const Color surfaceVariant = Color(0xFFE6F2F0);
  static const Color border = Color(0xFFD7E6E3);
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey600;
  static const Color shadow = Color(0x220F172A);

  // Specific Feature Colors
  static const Color availableBike = success;
  static const Color bookedBike = error;
  static const Color maintenanceBike = warning;
  static const Color stationMarker = primary;
  static const Color selectedStation = primaryDark;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFB7185)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7FBFA), Color(0xFFEFF6F5)],
  );
}
