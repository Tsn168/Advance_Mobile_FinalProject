import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../ui/screens/map/view_model/map_viewmodel.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';

class MapPreviewWidget extends StatelessWidget {
  final VoidCallback onTap;

  const MapPreviewWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, mapViewModel, _) {
        if (mapViewModel.stations.isEmpty) {
          return _buildPlaceholder();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AbsorbPointer(
                  child: GoogleMap(
                    initialCameraPosition: mapViewModel.initialCameraPosition,
                    markers: mapViewModel.markers,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Explore Available Stations',
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
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.map_rounded, size: 44, color: AppColors.white),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Explore Live Map',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Find your nearest station',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
