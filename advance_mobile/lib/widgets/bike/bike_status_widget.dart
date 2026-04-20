import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_card.dart';

enum BikeStatus { available, booked, maintenance, charging }

class BikeStatusWidget extends StatelessWidget {
  final int bikeId;
  final BikeStatus status;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final double? batteryLevel;
  final bool showDetails;

  const BikeStatusWidget({
    super.key,
    required this.bikeId,
    required this.status,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.batteryLevel,
    this.showDetails = true,
  });

  Color get statusColor {
    switch (status) {
      case BikeStatus.available:
        return AppColors.success;
      case BikeStatus.booked:
        return AppColors.error;
      case BikeStatus.maintenance:
        return AppColors.warning;
      case BikeStatus.charging:
        return AppColors.info;
    }
  }

  Color get backgroundColor {
    return statusColor.withValues(alpha: 0.1);
  }

  IconData get statusIcon {
    switch (status) {
      case BikeStatus.available:
        return Icons.check_circle;
      case BikeStatus.booked:
        return Icons.lock;
      case BikeStatus.maintenance:
        return Icons.warning;
      case BikeStatus.charging:
        return Icons.battery_charging_full;
    }
  }

  String get statusText {
    switch (status) {
      case BikeStatus.available:
        return 'Available';
      case BikeStatus.booked:
        return 'Booked';
      case BikeStatus.maintenance:
        return 'Maintenance';
      case BikeStatus.charging:
        return 'Charging';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: backgroundColor,
      border: Border.all(color: statusColor, width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bike #$bikeId', style: AppTextStyles.h5),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: AppDimensions.iconSmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        statusText,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: AppDimensions.iconLarge,
                ),
              ),
            ],
          ),

          if (showDetails) ...[const SizedBox(height: AppSpacing.lg)],

          // Battery Level (if available)
          if (batteryLevel != null && showDetails) ...[_buildBatteryInfo()],

          // Last Maintenance (if available)
          if (lastMaintenanceDate != null && showDetails) ...[
            _buildMaintenanceInfo(),
          ],

          // Next Maintenance (if available)
          if (nextMaintenanceDate != null && showDetails) ...[
            _buildNextMaintenanceInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildBatteryInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Battery Level',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey600),
            ),
            Text(
              '${batteryLevel!.toStringAsFixed(0)}%',
              style: AppTextStyles.label.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Battery progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: batteryLevel! / 100,
            minHeight: 6,
            backgroundColor: AppColors.grey300,
            valueColor: AlwaysStoppedAnimation<Color>(
              batteryLevel! > 50
                  ? AppColors.success
                  : batteryLevel! > 20
                  ? AppColors.warning
                  : AppColors.error,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildMaintenanceInfo() {
    final formattedDate =
        '${lastMaintenanceDate!.day}/${lastMaintenanceDate!.month}/${lastMaintenanceDate!.year}';
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: AppDimensions.iconSmall,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Maintenance',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formattedDate,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildNextMaintenanceInfo() {
    final formattedDate =
        '${nextMaintenanceDate!.day}/${nextMaintenanceDate!.month}/${nextMaintenanceDate!.year}';
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.info,
              size: AppDimensions.iconSmall,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Maintenance',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formattedDate,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
