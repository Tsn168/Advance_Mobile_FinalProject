import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';

class StationAvailabilityButtons extends StatelessWidget {
  final int availableBikes;
  final int emptySlots;
  final VoidCallback? onViewBikes;

  const StationAvailabilityButtons({
    super.key,
    required this.availableBikes,
    required this.emptySlots,
    this.onViewBikes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
         children: [
         Expanded(
           child: _AvailabilityButton(
             count: availableBikes,
             label: 'BIKES AVAILABLE',
             color: AppColors.teal,
             onTap: onViewBikes,
           ),
         ),
         const SizedBox(width: 16),
         Expanded(
           child: _AvailabilityButton(
             count: emptySlots,
             label: 'EMPTY SLOTS',
             color: AppColors.lightBlue,
             onTap: null,
           ),
         ),
       ],
    );
  }
}

class _AvailabilityButton extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _AvailabilityButton({
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
