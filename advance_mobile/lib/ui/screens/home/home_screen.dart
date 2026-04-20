import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../theme/app_colors.dart';
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
        actions: [
          IconButton(
            onPressed: onNavigateToMap,
            icon: const Icon(Icons.explore_outlined),
            tooltip: 'Explore map',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<PassViewModel>().loadUserPasses();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _buildHeroPanel(context),
              const SizedBox(height: AppSpacing.huge),
              _buildPassCard(context),
              const SizedBox(height: AppSpacing.huge),
              _buildBookingCard(context),
              const SizedBox(height: AppSpacing.huge),
              _buildQuickStats(context),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Smarter Today',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap into nearby stations, secure your bike, and move through the city faster.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoPill(icon: Icons.route, label: 'Fast Pickup'),
              _InfoPill(icon: Icons.verified, label: 'Reliable Bikes'),
              _InfoPill(icon: Icons.bolt, label: 'Live Availability'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassCard(BuildContext context) {
    return Consumer<PassViewModel>(
      builder: (context, passViewModel, _) {
        final activePass = passViewModel.activePass;
        final currentPass = activePass;
        final usageRatio = activePass == null
            ? 0.0
            : (activePass.remainingDays / activePass.type.durationDays)
                  .clamp(0.0, 1.0)
                  .toDouble();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_membership,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Active Pass', style: AppTextStyles.h5),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (passViewModel.state == AppState.loading)
                  const Center(child: CircularProgressIndicator())
                else if (currentPass != null) ...[
                  Text(
                    currentPass.type.displayName,
                    style: AppTextStyles.h4.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Valid for ${currentPass.remainingDays} days',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: usageRatio,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: onNavigateToPlans,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Change Pass'),
                  ),
                ] else ...[
                  Text(
                    'No active pass found. Select a pass to start booking bikes.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
                Text('Current Booking', style: AppTextStyles.h5),
                const SizedBox(height: AppSpacing.md),
                if (bookingViewModel.state == AppState.loading)
                  const Center(child: CircularProgressIndicator())
                else if (activeBooking == null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_bike,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'No active booking',
                        style: AppTextStyles.bodyLarge.copyWith(
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
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Bike ${activeBooking.bikeId} at ${activeBooking.stationId}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Slot ${activeBooking.slotNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
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
            Text('Quick Stats', style: AppTextStyles.h5),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    (constraints.maxWidth - AppSpacing.md * 2) / 3;
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(title: 'Pass', value: passName),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(title: 'Days Left', value: remaining),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: _StatCard(
                        title: 'Booking',
                        value: bookingViewModel.hasActiveBooking
                            ? 'Active'
                            : 'None',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
