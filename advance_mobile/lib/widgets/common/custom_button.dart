import 'package:flutter/material.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final EdgeInsets padding;
  final double borderRadius;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 56.0,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.textColor = Colors.white,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.borderRadius = 12.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: isEnabled
                  ? backgroundColor
                  : backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 20),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Text(
                          label,
                          style: AppTextStyles.buttonText.copyWith(
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
