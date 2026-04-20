import 'package:flutter/material.dart';

import '../../../model/bike/bike.dart';
import '../../../model/station/station.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.station,
    required this.bike,
  });

  final Station station;
  final Bike bike;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Station: ${station.name}'),
                  const SizedBox(height: 6),
                  Text('Bike: #${bike.id}'),
                  const SizedBox(height: 6),
                  Text('Slot: ${bike.slotNumber}'),
                  const SizedBox(height: 6),
                  Text('Condition: ${bike.condition.displayName}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
