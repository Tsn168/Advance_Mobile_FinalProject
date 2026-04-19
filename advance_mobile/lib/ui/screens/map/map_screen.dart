import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/bike/bike.dart';
import '../../../model/station/station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'view_model/bike_viewmodel.dart';
import '../home/view_model/booking_viewmodel.dart';
import 'view_model/map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.onNavigateToPlans});

  final VoidCallback onNavigateToPlans;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<MapViewModel, BikeViewModel, BookingViewModel>(
      builder: (context, mapViewModel, bikeViewModel, bookingViewModel, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Find Stations'), centerTitle: true),
          body: Column(
            children: [
              _buildMapPlaceholder(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _buildStationList(
                  context,
                  mapViewModel,
                  bikeViewModel,
                  bookingViewModel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 42, color: AppColors.primary),
            SizedBox(height: AppSpacing.xs),
            Text('Google Maps integration by Somnang'),
          ],
        ),
      ),
    );
  }

  Widget _buildStationList(
    BuildContext context,
    MapViewModel mapViewModel,
    BikeViewModel bikeViewModel,
    BookingViewModel bookingViewModel,
  ) {
    if (mapViewModel.state == AppState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mapViewModel.state == AppState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(mapViewModel.errorMessage ?? 'Failed to load stations'),
        ),
      );
    }

    final stations = mapViewModel.stations;
    if (stations.isEmpty) {
      return const Center(child: Text('No stations available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        final isSelected = mapViewModel.selectedStation?.id == station.id;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            station.address ?? 'No address',
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _availabilityBadge(station),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          mapViewModel.selectStation(station.id);
                          await bikeViewModel.loadBikesByStation(station.id);
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('View Bikes'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: station.hasAvailableBikes
                            ? () async {
                                await bikeViewModel.loadBikesByStation(
                                  station.id,
                                );
                                await _attemptBooking(
                                  station,
                                  bikeViewModel,
                                  bookingViewModel,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.directions_bike),
                        label: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
                if (isSelected && bikeViewModel.bikes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Station bikes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: bikeViewModel.bikes.map((bike) {
                      return Chip(
                        label: Text(
                          '#${bike.slotNumber} ${bike.status.displayName}',
                        ),
                        backgroundColor: bike.status == BikeStatus.available
                            ? AppColors.success.withValues(alpha: 0.18)
                            : AppColors.grey200,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _availabilityBadge(Station station) {
    final hasBikes = station.hasAvailableBikes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasBikes
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${station.availableBikes} bikes',
        style: TextStyle(
          color: hasBikes ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _attemptBooking(
    Station station,
    BikeViewModel bikeViewModel,
    BookingViewModel bookingViewModel,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    final availableBikes = bikeViewModel.availableBikes;
    if (availableBikes.isEmpty) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('No available bikes at this station')),
      );
      return;
    }

    final bike = availableBikes.first;
    final success = await bookingViewModel.bookBike(
      bikeId: bike.id,
      stationId: station.id,
      slotNumber: bike.slotNumber,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Booked bike ${bike.id} at ${station.name}'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    if (bookingViewModel.flowStatus ==
        BookingFlowStatus.requiresPassSelection) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Active pass required. Redirecting to Plans tab...'),
          backgroundColor: AppColors.error,
        ),
      );
      widget.onNavigateToPlans();
      bookingViewModel.clearBookingPrompt();
      return;
    }

    final message = bookingViewModel.errorMessage ?? 'Booking failed';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
