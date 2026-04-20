import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import 'custom_button.dart';

class ErrorDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonLabel;
  final String? secondaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onDismiss;

  const ErrorDialogWidget({
    Key? key,
    required this.title,
    required this.message,
    this.primaryButtonLabel = 'OK',
    this.secondaryButtonLabel,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
      ),
      actions: [
        if (secondaryButtonLabel != null)
          CustomButton(
            label: secondaryButtonLabel!,
            onPressed:
                onSecondaryPressed ??
                () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
            backgroundColor: AppColors.grey300,
            textColor: AppColors.grey700,
            width: 120,
            height: 40,
          ),
        const SizedBox(width: AppSpacing.md),
        CustomButton(
          label: primaryButtonLabel ?? 'OK',
          onPressed:
              onPrimaryPressed ??
              () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
          backgroundColor: AppColors.error,
          width: 120,
          height: 40,
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? primaryButtonLabel,
    String? secondaryButtonLabel,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialogWidget(
        title: title,
        message: message,
        primaryButtonLabel: primaryButtonLabel,
        secondaryButtonLabel: secondaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }
}
