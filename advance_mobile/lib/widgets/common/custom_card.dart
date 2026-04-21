import 'package:flutter/material.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.elevation = 2.0,
    this.borderRadius = AppDimensions.cardBorderRadius,
    this.padding = const EdgeInsets.all(AppDimensions.cardPadding),
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: elevation,
                offset: Offset(0, elevation / 2),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
