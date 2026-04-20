import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';

enum PassBadgeType { day, monthly, annual, active, inactive }

class PassBadge extends StatelessWidget {
  final PassBadgeType badgeType;
  final String label;
  final bool isActive;

  const PassBadge({
    Key? key,
    required this.badgeType,
    required this.label,
    this.isActive = false,
  }) : super(key: key);

  Color get backgroundColor {
    if (isActive) {
      return AppColors.success.withOpacity(0.2);
    }

    switch (badgeType) {
      case PassBadgeType.day:
        return AppColors.info.withOpacity(0.2);
      case PassBadgeType.monthly:
        return AppColors.primary.withOpacity(0.2);
      case PassBadgeType.annual:
        return AppColors.warning.withOpacity(0.2);
      case PassBadgeType.active:
        return AppColors.success.withOpacity(0.2);
      case PassBadgeType.inactive:
        return AppColors.grey300.withOpacity(0.5);
    }
  }

  Color get textColor {
    if (isActive) {
      return AppColors.success;
    }

    switch (badgeType) {
      case PassBadgeType.day:
        return AppColors.info;
      case PassBadgeType.monthly:
        return AppColors.primary;
      case PassBadgeType.annual:
        return AppColors.warning;
      case PassBadgeType.active:
        return AppColors.success;
      case PassBadgeType.inactive:
        return AppColors.grey600;
    }
  }

  IconData get icon {
    if (isActive) {
      return Icons.check_circle;
    }

    switch (badgeType) {
      case PassBadgeType.day:
        return Icons.calendar_today;
      case PassBadgeType.monthly:
        return Icons.calendar_month;
      case PassBadgeType.annual:
        return Icons.card_giftcard;
      case PassBadgeType.active:
        return Icons.check_circle;
      case PassBadgeType.inactive:
        return Icons.close_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
