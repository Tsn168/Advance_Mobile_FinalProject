import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/station/station.dart';
import '../../../model/bike/bike.dart';
import '../../../service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../station_detail/station_detail_screen.dart';
import '../station_detail/view_model/station_detail_view_model.dart';
import 'view_model/map_viewmodel.dart';
import 'view_model/bike_viewmodel.dart';
import 'view_model/booking_viewmodel.dart';
import 'widgets/active_booking_overlay.dart';
import '../../../widgets/station/station_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.onNavigateToPlans,
    this.showMapWidget = true,
  });

  final VoidCallback onNavigateToPlans;
  final bool showMapWidget;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedStationId;

  @override
  Widget build(BuildContext context) {
    final bikeViewModel = context.watch<BikeViewModel>();
    final bookingViewModel = context.watch<BookingViewModel>();

    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu),
            ),
            title: const Text(
              'KINETIC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.person, size: 18, color: AppColors.primary),
                ),
              ),
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
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildBikeStatsHeader(mapViewModel),
                    ),
                    SliverToBoxAdapter(
                      child: _buildGoogleMap(mapViewModel),
                    ),
                    _buildStationListSliver(
                        context, mapViewModel, bikeViewModel, bookingViewModel),
                    // Add some bottom padding so cards are not hidden by the overlay
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ActiveBookingOverlay(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBikeStatsHeader(MapViewModel mapViewModel) {
    int totalBikes = 0;
    int totalAvailable = 0;

    for (final station in mapViewModel.stations) {
      totalBikes += station.totalSlots;
      totalAvailable += station.availableBikes;
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Bikes',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.87),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$totalAvailable/$totalBikes',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bike,
              color: AppColors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(MapViewModel mapViewModel) {
    if (!widget.showMapWidget || mapViewModel.stations.isEmpty) {
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
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: mapViewModel.initialCameraPosition,
            onMapCreated: mapViewModel.onMapCreated,
            markers: mapViewModel.markers,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Find your nearest station',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF455A64),
                ),
              ),
            ),
          ),
        ],
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
              'Station Overview',
              style: AppTextStyles.h5.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Find your nearest station',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.86),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationListSliver(
    BuildContext context,
    MapViewModel mapViewModel,
    BikeViewModel bikeViewModel,
    BookingViewModel bookingViewModel,
  ) {
    if (mapViewModel.state == AppState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (mapViewModel.state == AppState.error) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(mapViewModel.errorMessage ?? 'Failed to load stations'),
          ),
        ),
      );
    }

    final stations = mapViewModel.stations;
    if (stations.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No stations available')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final station = stations[index];
            final isSelected = mapViewModel.selectedStation?.id == station.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StationCard(
                    stationName: station.name,
                    stationId: station.id,
                    totalSlots: station.totalSlots,
                    availableSlots: station.availableBikes,
                    location: station.address ?? 'No address',
                    onTap: () async {
                      mapViewModel.selectStation(station.id);
                      setState(() {
                        _selectedStationId = station.id;
                      });
                      await bikeViewModel.loadBikesByStation(station.id);
                    },
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openStationDetail(station.id),
                            icon: const Icon(Icons.list),
                            label: const Text('View Bikes'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: station.hasAvailableBikes
                                ? () => _attemptBooking(
                                    context, station, bikeViewModel, bookingViewModel)
                                : null,
                            icon: const Icon(Icons.directions_bike),
                            label: const Text('Book Now'),
                          ),
                        ),
                      ],
                    ),
                    if (bikeViewModel.bikes.isNotEmpty &&
                        bikeViewModel.stationId == station.id) ...[
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
                ],
              ),
            );
          },
          childCount: stations.length,
        ),
      ),
    );
  }

  Future<void> _attemptBooking(
    BuildContext context,
    Station station,
    BikeViewModel bikeViewModel,
    BookingViewModel bookingViewModel,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    
    // Find the first available bike
    final availableBikes = bikeViewModel.bikes.where((b) => b.status == BikeStatus.available).toList();
    if (availableBikes.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('No available bikes in this station.')));
      return;
    }

    final bike = availableBikes.first;
    
    final success = await bookingViewModel.bookBike(
      bikeId: bike.id,
      stationId: station.id,
      slotNumber: bike.slotNumber,
    );

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Bike #${bike.slotNumber} booked successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(bookingViewModel.errorMessage ?? 'Booking failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openStationDetail(String stationId) async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<StationDetailViewModel>(
          create: (_) => getIt<StationDetailViewModel>(),
          child: StationDetailScreen(stationId: stationId),
        ),
      ),
    );
  }
}
