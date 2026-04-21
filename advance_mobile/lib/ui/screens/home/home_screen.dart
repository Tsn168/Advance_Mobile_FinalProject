import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'view_model/booking_viewmodel.dart';
import '../plans/view_model/pass_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateToMap,
    required this.onNavigateToPlans,
  });

  final VoidCallback onNavigateToMap;
  final VoidCallback onNavigateToPlans;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Sharing'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<PassViewModel>().loadUserPasses();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildPassCard(context),
            const SizedBox(height: AppSpacing.huge),
            _buildBookingCard(context),
            const SizedBox(height: AppSpacing.huge),
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPassCard(BuildContext context) {
    return Consumer<PassViewModel>(
      builder: (context, passViewModel, _) {
        final activePass = passViewModel.activePass;
        final hasActivePass = activePass != null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.card_membership,
                      color: AppColors.primary,
                      semanticLabel: 'Pass Icon',
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Active Pass',
                      style: AppTextStyles.h5,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (passViewModel.state == AppState.loading)
                  const Center(child: CircularProgressIndicator())
                else if (hasActivePass) ...[
                  Text(
                    activePass.type.displayName,
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Valid for ${activePass.remainingDays} days',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: onNavigateToPlans,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Change Pass'),
                  ),
                ] else ...[
                  const Text(
                    'No active pass found. Select a pass to start booking bikes.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: onNavigateToPlans,
                    icon: const Icon(Icons.add_card),
                    label: const Text('Select a Pass'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    return Consumer<BookingViewModel>(
      builder: (context, bookingViewModel, _) {
        final activeBooking = bookingViewModel.activeBooking;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Booking',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppSpacing.md),
                if (bookingViewModel.state == AppState.loading)
                  const Center(child: CircularProgressIndicator())
                else if (activeBooking == null) ...[
                  const Row(
                    children: [
                      Icon(Icons.directions_bike, color: AppColors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'No active booking',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: onNavigateToMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Book from Map'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Bike ${activeBooking.bikeId} at ${activeBooking.stationId}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Slot ${activeBooking.slotNumber}'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context
                                .read<BookingViewModel>()
                                .cancelCurrentBooking();
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<BookingViewModel>()
                                .completeCurrentBooking(
                                  rideDistance: 4.6,
                                  rideDuration: 28,
                                );
                          },
                          icon: const Icon(Icons.flag),
                          label: const Text('Complete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer2<PassViewModel, BookingViewModel>(
      builder: (context, passViewModel, bookingViewModel, _) {
        final pass = passViewModel.activePass;
        final passName = pass?.type.displayName ?? 'No Pass';
        final remaining = pass?.remainingDays.toString() ?? '-';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatCard(title: 'Pass', value: passName),
                _StatCard(title: 'Days Left', value: remaining),
                _StatCard(
                  title: 'Booking',
                  value: bookingViewModel.hasActiveBooking ? 'Active' : 'None',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Text(
                value,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                semanticsLabel: '$title: $value',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.grey600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
