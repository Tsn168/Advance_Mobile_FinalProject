import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_button.dart';
import '../common/custom_card.dart';

class BikeCard extends StatelessWidget {
  final int slotNumber;
  final String bikeModel;
  final String condition;
  final bool isAvailable;
  final VoidCallback onBook;
  final double? batteryLevel;

  const BikeCard({
    super.key,
    required this.slotNumber,
    required this.bikeModel,
    required this.condition,
    required this.isAvailable,
    required this.onBook,
    this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Slot Number and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Slot #$slotNumber', style: AppTextStyles.h5),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    bikeModel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Booked',
                  style: AppTextStyles.caption.copyWith(
                    color: isAvailable ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Condition
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.grey600,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Condition: $condition',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),

          // Battery Level (if provided)
          if (batteryLevel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.battery_full,
                  color: batteryLevel! > 50
                      ? AppColors.success
                      : AppColors.warning,
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
                            'Battery',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          Text(
                            '${batteryLevel!.toStringAsFixed(0)}%',
                            style: AppTextStyles.caption.copyWith(
                              color: batteryLevel! > 50
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: batteryLevel! / 100,
                          minHeight: 6,
                          backgroundColor: AppColors.grey300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            batteryLevel! > 50
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Book Button
          CustomButton(
            label: isAvailable ? 'Book Now' : 'Not Available',
            onPressed: isAvailable ? onBook : () {},
            width: double.infinity,
            backgroundColor: isAvailable
                ? AppColors.primary
                : AppColors.grey400,
            icon: Icons.directions_bike,
          ),
        ],
      ),
    );
  }
}
