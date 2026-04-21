import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_button.dart';
import '../common/custom_card.dart';

enum PassType { day, monthly, annual }

class SubscriptionCard extends StatelessWidget {
  final PassType passType;
  final double price;
  final String originalPrice;
  final String description;
  final String? imageUrl;
  final VoidCallback onChoose;
  final bool isActive;
  final bool isPopular;

  const SubscriptionCard({
    super.key,
    required this.passType,
    required this.price,
    required this.originalPrice,
    required this.description,
    this.imageUrl,
    required this.onChoose,
    this.isActive = false,
    this.isPopular = false,
  });

  String get passTitle {
    switch (passType) {
      case PassType.day:
        return 'Day Pass';
      case PassType.monthly:
        return 'Monthly Pass';
      case PassType.annual:
        return 'Annual Pass';
    }
  }

  Color get badgeColor {
    if (isActive) {
      return AppColors.success;
    }
    if (isPopular) {
      return AppColors.primary;
    }
    return AppColors.info;
  }

  String get badgeText {
    if (isActive) {
      return 'ACTIVE';
    }
    if (isPopular) {
      return 'POPULAR';
    }
    return 'BEST VALUE';
  }

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
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: AppColors.grey200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.cardBorderRadius),
                      topRight: Radius.circular(AppDimensions.cardBorderRadius),
                    ),
                  ),
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              // Badge
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                   decoration: BoxDecoration(
                     color: badgeColor,
                     borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                   ),
                  child: Text(
                    badgeText,
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
                // Pass Title
                Text(
                  passTitle,
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$$price.00',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'per mo',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grey600,
                            fontSize: 10,
                          ),
                        ),
                        if (originalPrice.isNotEmpty)
                          Text(
                            originalPrice,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey500,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Choose Button
                CustomButton(
                  label: 'Choose',
                  onPressed: onChoose,
                  width: double.infinity,
                  backgroundColor: AppColors.primary,
                  height: 48,
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
