import 'package:flutter/material.dart';

class StationMarker extends StatelessWidget {
  final int availableBikes;
  final bool isSelected;
  final VoidCallback? onTap;

  const StationMarker({
    super.key,
    required this.availableBikes,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? const Color(0xFF00C853) : Colors.white;
    final borderColor = isSelected
        ? const Color(0xFF00C853)
        : const Color(0xFFB0BEC5);
    final textColor = isSelected ? Colors.white : const Color(0xFF263238);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$availableBikes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
