import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/bike/bike.dart';
import '../../../model/station/station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
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
          appBar: AppBar(
            title: const Text('Find Stations'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: mapViewModel.refreshStations,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh stations',
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: Column(
              children: [
                _buildGoogleMap(mapViewModel),
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
          ),
        );
      },
    );
  }

  Widget _buildGoogleMap(MapViewModel mapViewModel) {
    if (mapViewModel.stations.isEmpty) {
      return _buildMapPlaceholder();
    }

    return Container(
      height: 220,
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: mapViewModel.initialCameraPosition,
        onMapCreated: mapViewModel.onMapCreated,
        markers: mapViewModel.markers,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 168,
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 44, color: AppColors.white),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Live Station Overview',
              style: AppTextStyles.h5.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Map will appear after stations load',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.86),
              ),
            ),
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
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
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
                          Text(station.name, style: AppTextStyles.h5),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            station.address ?? 'No address',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: bikeViewModel.bikes.map((bike) {
                      return Chip(
                        label: Text(
                          '#${bike.slotNumber} ${bike.status.displayName}',
                          style: AppTextStyles.labelMedium,
                        ),
                        backgroundColor: bike.status == BikeStatus.available
                            ? AppColors.success.withValues(alpha: 0.18)
                            : AppColors.surfaceVariant,
                        side: BorderSide(
                          color: bike.status == BikeStatus.available
                              ? AppColors.success.withValues(alpha: 0.32)
                              : AppColors.border,
                        ),
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
          fontWeight: FontWeight.w700,
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
