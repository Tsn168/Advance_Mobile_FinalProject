import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import 'custom_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonLabel;
  final String cancelButtonLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmButtonLabel = 'Confirm',
    this.cancelButtonLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.bottomSheetBorderRadius)),
      title: Text(
        title,
        style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
      ),
      actions: [
        CustomButton(
          label: cancelButtonLabel,
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          backgroundColor: AppColors.grey300,
          textColor: AppColors.grey700,
          width: 120,
          height: 40,
        ),
        const SizedBox(width: AppSpacing.md),
        CustomButton(
          label: confirmButtonLabel,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          backgroundColor: AppColors.primary,
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
    String confirmButtonLabel = 'Confirm',
    String cancelButtonLabel = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmButtonLabel: confirmButtonLabel,
        cancelButtonLabel: cancelButtonLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
