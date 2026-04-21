import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/station/station.dart';
import '../../../service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/station_bottom_sheet.dart';
import '../../widgets/station_marker.dart';
import '../station_detail/station_detail_screen.dart';
import '../station_detail/view_model/station_detail_view_model.dart';
import 'view_model/map_viewmodel.dart';
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
  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                _buildBikeStatsHeader(mapViewModel),
                _buildGoogleMap(mapViewModel),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _buildStationMarkers(context, mapViewModel),
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

  Widget _buildStationMarkers(
    BuildContext context,
    MapViewModel mapViewModel,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Tap a station marker',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF455A64),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            itemCount: stations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final station = stations[index];
              final isSelected = mapViewModel.selectedStationId == station.id;

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
                  await bikeViewModel.loadBikesByStation(station.id);
                },
              ),
              if (isSelected) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (!context.mounted) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  StationDetailScreen(stationId: station.id),
                            ),
                          );
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
                if (bikeViewModel.bikes.isNotEmpty) ...[
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
        ),
      ],
    );
  }

  Future<void> _attemptBooking(
    Station station,
    BikeViewModel bikeViewModel,
    BookingViewModel bookingViewModel,
  ) async {
    mapViewModel.selectStation(stationId);

    final openStationDetail = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer<MapViewModel>(
          builder: (context, liveMapViewModel, _) {
            final selectedId =
                liveMapViewModel.selectedStationId;
            final station = _findStationById(selectedId);

            if (station == null) {
              return const SizedBox.shrink();
            }

            return StationBottomSheet(
              station: station,
              onViewBikes: () => Navigator.of(sheetContext).pop(true),
            );
          },
        );
      },
    );

    if (openStationDetail == true) {
      await _openStationDetail();
    }
  }

  Future<void> _openStationDetail() async {
    final stationId = context.read<MapViewModel>().selectedStationId;
    if (stationId == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<StationDetailViewModel>(
          create: (_) => getIt<StationDetailViewModel>(),
          child: StationDetailScreen(stationId: stationId),
        ),
      ),
    );
  }

  Station? _findStationById(String? stationId) {
    if (stationId == null) {
      return null;
    }

    return context.read<MapViewModel>().getStationById(stationId);
  }
}
