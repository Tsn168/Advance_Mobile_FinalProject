import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue Colors
  static const Color primary = Color(0xFF2196F3); // Main blue
  static const Color primaryDark = Color(0xFF1976D2); // Darker blue
  static const Color primaryLight = Color(0xFF64B5F6); // Lighter blue

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color accent = Color(0xFFFF9800);

  // Semantic
  static const Color disabled = grey400;
  static const Color divider = grey300;
  static const Color background = grey100;
  static const Color surface = white;
  static const Color surfaceVariant = grey200;
  static const Color border = grey300;
  static const Color textPrimary = grey800;
  static const Color textSecondary = grey600;

  // Specific Feature Colors
  static const Color availableBike = Color(0xFF4CAF50);
  static const Color bookedBike = Color(0xFFF44336);
  static const Color maintenanceBike = Color(0xFFFFC107);
  static const Color stationMarker = Color(0xFF2196F3);
  static const Color selectedStation = Color(0xFF1976D2);
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

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9FBFF), Color(0xFFF2F6FF)],
  );
}
