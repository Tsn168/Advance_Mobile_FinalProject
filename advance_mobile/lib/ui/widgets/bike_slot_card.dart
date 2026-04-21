import 'package:flutter/material.dart';

import '../../model/bike/bike.dart';
import '../../ui/theme/app_colors.dart';

class BikeSlotCard extends StatelessWidget {
  static const Color _availableCardColor = AppColors.purpleBlue; // Purple-Blue for bike cards
  static const Color _unavailableCardColor = Color(0xFF9EA7B8); // Keep existing for now
  static const Color _emptySlotCardColor = Color(0xFFE3E8F2); // Keep existing for now

  final Bike? bike;
  final int slotNumber;
  final VoidCallback? onTap;

  const BikeSlotCard({
    super.key,
    required this.bike,
    required this.slotNumber,
    this.onTap,
  });

  bool get _isEmptySlot => bike == null;
  bool get _isAvailable => bike?.isAvailable ?? false;

  @override
  Widget build(BuildContext context) {
    final cardColor = _isEmptySlot
        ? _emptySlotCardColor
        : _isAvailable
        ? _availableCardColor
        : _unavailableCardColor;

    final textColor = _isEmptySlot ? const Color(0xFF546E7A) : Colors.white;
    final iconColor = _isEmptySlot
        ? const Color(0xFF90A4AE)
        : _isAvailable
        ? Colors.white
        : const Color(0xFFF1F4F8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: _isEmptySlot
                ? Border.all(color: const Color(0xFFCFD8DC), width: 1.2)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Icon(Icons.directions_bike, size: 56, color: iconColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEmptySlot ? 'Empty Slot' : 'BikeID: #${bike!.id}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Slot: no.${slotNumber.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withValues(
                          alpha: _isEmptySlot ? 1 : 0.92,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(
                      label: _isEmptySlot
                          ? 'EMPTY'
                          : _isAvailable
                          ? 'AVAILABLE'
                          : 'UNAVAILABLE',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (label) {
       case 'AVAILABLE':
         background = AppColors.teal;
         foreground = Colors.white;
         break;
      case 'UNAVAILABLE':
        background = const Color(0xFFFFCDD2);
        foreground = const Color(0xFFB71C1C);
        break;
      default:
        background = const Color(0xFFCFD8DC);
        foreground = const Color(0xFF455A64);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: foreground,
        ),
      ),
    );
  }
}
