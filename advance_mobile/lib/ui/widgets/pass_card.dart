import 'package:flutter/material.dart';

import '../../model/pass/pass.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';

class PassCard extends StatelessWidget {
  final PassType passType;
  final String badgeText;
  final Color badgeColor;
  final String? heroImagePath;
  final String description;
  final double? displayPrice;
  final bool isSelected;
  final bool isChooseEnabled;
  final VoidCallback onChoose;

  const PassCard({
    super.key,
    required this.passType,
    required this.badgeText,
    required this.badgeColor,
    this.heroImagePath,
    required this.description,
    this.displayPrice,
    this.isSelected = false,
    this.isChooseEnabled = true,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final priceToDisplay = displayPrice ?? passType.price;

     return Container(
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          border: isSelected
              ? Border.all(color: AppColors.green, width: 2)
              : null,
         boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.08),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroArea(
            heroImagePath: heroImagePath,
            badgeText: badgeText,
            badgeColor: badgeColor,
          ),
           Padding(
             padding: EdgeInsets.all(AppDimensions.cardPadding),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passType.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '\$${priceToDisplay.toStringAsFixed(2)}',
                        style: const TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                       color: AppColors.blue,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${_periodContext(passType)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF607D8B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF546E7A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isChooseEnabled ? onChoose : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                      ),
                    ),
                    child: const Text(
                      'Choose',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _periodContext(PassType type) {
    switch (type) {
      case PassType.day:
        return 'single use';
      case PassType.weekly:
        return 'week';
      case PassType.monthly:
        return 'month';
      case PassType.annual:
        return 'year';
    }
  }
}

class _HeroArea extends StatelessWidget {
  final String? heroImagePath;
  final String badgeText;
  final Color badgeColor;

  const _HeroArea({
    required this.heroImagePath,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            width: double.infinity,
            height: 150,
            child: heroImagePath == null
                 ? Container(
                     color: const Color(0xFFE3F2FD),
                     alignment: Alignment.center,
                     child: const Icon(
                       Icons.directions_bike,
                       size: 56,
                       color: AppColors.blue,
                     ),
                   )
                 : Image.asset(
                     heroImagePath!,
                     fit: BoxFit.cover,
                     errorBuilder: (_, __, ___) {
                       return Container(
                         color: const Color(0xFFE3F2FD),
                         alignment: Alignment.center,
                         child: const Icon(
                           Icons.directions_bike,
                           size: 56,
                           color: AppColors.blue,
                         ),
                       );
                     },
                   ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (badgeText == 'BEST VALUE' || badgeText == 'BEST IDEA')
          Positioned(
            top: 12,
            right: 12,
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: AppColors.teal,
                 borderRadius: BorderRadius.circular(10),
               ),
               child: const Text(
                 'SELECTED',
                 style: TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.w700,
                   fontSize: 9,
                   letterSpacing: 0.4,
                 ),
               ),
            ),
          ),
      ],
    );
  }
}
