import 'package:flutter/material.dart';

import '../../model/pass/pass.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';

class PassInfoCard extends StatelessWidget {
  final Pass? activePass;
  final VoidCallback? onManage;

  const PassInfoCard({super.key, required this.activePass, this.onManage});

  @override
  Widget build(BuildContext context) {
   if (activePass == null) {
       return Container(
         width: double.infinity,
         padding: EdgeInsets.all(AppDimensions.cardPadding),
         decoration: BoxDecoration(
           color: const Color(0xFFF1F4F8),
           borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
         ),
        child: Row(
          children: [
            const Icon(
              Icons.card_membership,
              size: 36,
              color: Color(0xFF90A4AE),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Pass',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Purchase a pass to start riding',
                    style: TextStyle(fontSize: 13, color: Color(0xFF607D8B)),
                  ),
                ],
              ),
            ),
            if (onManage != null)
              IconButton(
                onPressed: onManage,
                icon: const Icon(Icons.settings, color: Color(0xFF607D8B)),
              ),
          ],
        ),
      );
    }

     final pass = activePass!;

     return Container(
       width: double.infinity,
       padding: EdgeInsets.all(AppDimensions.cardPadding),
       decoration: BoxDecoration(
         gradient: const LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
           colors: [Color(0xFF00695C), Color(0xFF00897B)],
         ),
         borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
       ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             'MEMBERSHIP STATUS',
             style: AppTextStyles.caption.copyWith(
               color: Colors.white.withValues(alpha: 0.82),
               fontWeight: FontWeight.w700,
               letterSpacing: 0.45,
             ),
           ),
           const SizedBox(height: AppSpacing.sm),
           Text(
             '${pass.type.displayName} Active',
             style: AppTextStyles.h5.copyWith(
               color: Colors.white,
               fontWeight: FontWeight.bold,
             ),
           ),
           const SizedBox(height: AppSpacing.xs),
           Text(
             'Expires: ${_formatDate(pass.expiryDate)}',
             style: AppTextStyles.bodySmall.copyWith(
               color: Colors.white.withValues(alpha: 0.9),
               fontWeight: FontWeight.w500,
             ),
           ),
         ],
       ),
          ),
          IconButton(
            onPressed: onManage,
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }
}
