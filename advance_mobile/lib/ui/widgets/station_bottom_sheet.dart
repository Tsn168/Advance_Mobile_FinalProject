import 'package:flutter/material.dart';

import '../../model/station/station.dart';
import 'station_availability_buttons.dart';

class StationBottomSheet extends StatelessWidget {
  final Station station;
  final VoidCallback? onViewBikes;

  const StationBottomSheet({
    super.key,
    required this.station,
    this.onViewBikes,
  });

  @override
  Widget build(BuildContext context) {
    final emptySlots = (station.totalSlots - station.availableBikes).clamp(
      0,
      station.totalSlots,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Station: ${station.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SELECTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF607D8B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  station.address ?? 'Unknown location',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF607D8B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StationAvailabilityButtons(
            availableBikes: station.availableBikes,
            emptySlots: emptySlots,
            onViewBikes: onViewBikes,
          ),
        ],
      ),
    );
  }
}
