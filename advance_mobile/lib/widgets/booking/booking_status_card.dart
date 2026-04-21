import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_button.dart';
import '../common/custom_card.dart';

enum BookingStatus { pending, active, completed, cancelled }

class BookingStatusCard extends StatelessWidget {
  final int bikeId;
  final String bikeName;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalPrice;
  final BookingStatus status;
  final VoidCallback? onReturnBike;
  final VoidCallback? onCancel;

  const BookingStatusCard({
    Key? key,
    required this.bikeId,
    required this.bikeName,
    required this.startTime,
    this.endTime,
    required this.totalPrice,
    required this.status,
    this.onReturnBike,
    this.onCancel,
  }) : super(key: key);

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.active:
        return AppColors.success;
      case BookingStatus.completed:
        return AppColors.info;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BookingStatus.pending:
        return Icons.hourglass_empty;
      case BookingStatus.active:
        return Icons.check_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = endTime?.difference(startTime) ?? Duration.zero;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.cardMarginVertical,
        horizontal: AppDimensions.cardMarginHorizontal,
      ),
      child: CustomCard(
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    bikeName,
                    style: AppTextStyles.bodySmall.copyWith(
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
                   color: statusColor.withOpacity(0.2),
                   borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                   border: Border.all(color: statusColor, width: 1.5),
                 ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Time Info
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.grey600,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start: ${startTime.toString().substring(0, 16)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    if (endTime != null)
                      Text(
                        'End: ${endTime!.toString().substring(0, 16)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Duration
          if (hours > 0 || minutes > 0)
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: AppColors.primary,
                  size: AppDimensions.iconSmall,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Duration: ${hours}h ${minutes}m',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price:',
                style: AppTextStyles.label.copyWith(color: AppColors.grey600),
              ),
              Text(
                '\$$totalPrice.00',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Buttons
          Row(
            children: [
              if (status == BookingStatus.active && onReturnBike != null) ...[
                Expanded(
                  child: CustomButton(
                    label: 'Return Bike',
                    onPressed: onReturnBike,
                    backgroundColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (status == BookingStatus.pending && onCancel != null)
                Expanded(
                  child: CustomButton(
                    label: 'Cancel Booking',
                    onPressed: onCancel,
                    backgroundColor: AppColors.error,
                 ),
               ],
             ],
           ),
         ],
       ),
     ),
   );
 }
}
