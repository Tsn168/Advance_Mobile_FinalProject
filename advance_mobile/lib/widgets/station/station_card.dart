import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_card.dart';

class StationCard extends StatelessWidget {
  final String stationName;
  final String stationId;
  final int totalSlots;
  final int availableSlots;
  final String location;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;

  const StationCard({
    Key? key,
    required this.stationName,
    required this.stationId,
    required this.totalSlots,
    required this.availableSlots,
    required this.location,
    this.latitude,
    this.longitude,
    this.onTap,
  }) : super(key: key);

  Color get slotsStatusColor {
    final percentage = availableSlots / totalSlots;
    if (percentage > 0.5) {
      return AppColors.success;
    } else if (percentage > 0.25) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String get slotsStatusText {
    if (availableSlots == 0) {
      return 'No Slots';
    } else if (availableSlots == totalSlots) {
      return 'All Available';
    } else {
      return '$availableSlots Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.cardMarginVertical,
        horizontal: AppDimensions.cardMarginHorizontal,
      ),
      child: CustomCard(
        onTap: onTap,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Station Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: AppTextStyles.h5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Station #$stationId',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: slotsStatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slotsStatusText,
                  style: AppTextStyles.caption.copyWith(
                    color: slotsStatusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Slots Information
          Row(
            children: [
              Icon(
                Icons.two_wheeler,
                color: AppColors.primary,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bike Slots',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          '$availableSlots / $totalSlots',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.bold,
                            color: slotsStatusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: availableSlots / totalSlots,
                        minHeight: 6,
                        backgroundColor: AppColors.grey300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          slotsStatusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.grey600,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
