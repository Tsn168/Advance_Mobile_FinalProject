import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';

class BikeSlotIndicator extends StatelessWidget {
  final int slotNumber;
  final bool isOccupied;
  final bool isSelected;
  final bool isMaintenanceMode;
  final VoidCallback onTap;

  const BikeSlotIndicator({
    super.key,
    required this.slotNumber,
    required this.isOccupied,
    required this.onTap,
    this.isSelected = false,
    this.isMaintenanceMode = false,
  });

  Color get backgroundColor {
    if (isSelected) {
      return AppColors.primary;
    }
    if (isMaintenanceMode) {
      return AppColors.warning.withValues(alpha: 0.2);
    }
    if (isOccupied) {
      return AppColors.error.withValues(alpha: 0.2);
    }
    return AppColors.success.withValues(alpha: 0.2);
  }

  Color get borderColor {
    if (isSelected) {
      return AppColors.primary;
    }
    if (isMaintenanceMode) {
      return AppColors.warning;
    }
    if (isOccupied) {
      return AppColors.error;
    }
    return AppColors.success;
  }

  IconData get iconData {
    if (isMaintenanceMode) {
      return Icons.build;
    }
    if (isOccupied) {
      return Icons.directions_bike;
    }
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: isSelected ? AppColors.white : borderColor,
              size: AppDimensions.iconMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '#$slotNumber',
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.white : borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
