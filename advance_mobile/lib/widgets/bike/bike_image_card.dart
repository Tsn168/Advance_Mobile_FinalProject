import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_button.dart';
import '../common/custom_card.dart';
import '../common/pass_badge.dart';

class BikeImageCard extends StatelessWidget {
  final int bikeId;
  final String bikeModel;
  final double price;
  final String? imageUrl;
  final String passType;
  final String condition;
  final bool isAvailable;
  final VoidCallback onChoose;
  final double? rating;

  const BikeImageCard({
    Key? key,
    required this.bikeId,
    required this.bikeModel,
    required this.price,
    this.imageUrl,
    required this.passType,
    required this.condition,
    required this.isAvailable,
    required this.onChoose,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.cardMarginVertical,
        horizontal: AppDimensions.cardMarginHorizontal,
      ),
      child: CustomCard(
        padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.cardBorderRadius),
                    topRight: Radius.circular(AppDimensions.cardBorderRadius),
                  ),
                  child: Image.network(
                    imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: AppColors.grey200,
                        child: const Center(
                          child: Icon(
                            Icons.directions_bike,
                            size: 60,
                            color: AppColors.grey400,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.cardBorderRadius),
                      topRight: Radius.circular(AppDimensions.cardBorderRadius),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_bike,
                      size: 60,
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              // Status Badge
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: Container(
                   padding: const EdgeInsets.symmetric(
                     horizontal: AppSpacing.md,
                     vertical: AppSpacing.sm,
                   ),
                   decoration: BoxDecoration(
                     color: isAvailable ? AppColors.success : AppColors.error,
                     borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                   ),
                  child: Text(
                    isAvailable ? 'Available' : 'Booked',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              // Bike ID
               Positioned(
                 top: AppSpacing.md,
                 left: AppSpacing.md,
                 child: Container(
                   padding: const EdgeInsets.symmetric(
                     horizontal: AppSpacing.md,
                     vertical: AppSpacing.xs,
                   ),
                   decoration: BoxDecoration(
                     color: AppColors.black.withOpacity(0.6),
                     borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                   ),
                   child: Text(
                     'Bike #$bikeId',
                     style: AppTextStyles.caption.copyWith(
                       color: AppColors.white,
                       fontWeight: FontWeight.bold,
                       fontSize: 10,
                     ),
                   ),
                 ),
               ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bike Model
                Text(
                  bikeModel,
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Price and Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$$price.00',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Pass Type Badge
                PassBadge(
                  badgeType: passType.toLowerCase() == 'day'
                      ? PassBadgeType.day
                      : passType.toLowerCase() == 'monthly'
                      ? PassBadgeType.monthly
                      : PassBadgeType.annual,
                  label: passType,
                ),
                const SizedBox(height: AppSpacing.md),

                // Condition
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.grey600,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Condition: $condition',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Choose Button
                 CustomButton(
                   label: 'Choose',
                   onPressed: isAvailable ? onChoose : null,
                   width: double.infinity,
                   backgroundColor: isAvailable
                       ? AppColors.primary
                       : AppColors.grey400,
                   height: 44,
                 ),
               ],
             ),
           ),
         ],
       ),
     ),
   );
 }

}