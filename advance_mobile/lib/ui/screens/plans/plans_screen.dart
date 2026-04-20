import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/pass/pass.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'view_model/pass_viewmodel.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PassViewModel>(
      builder: (context, passViewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscription Plans'),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: RefreshIndicator(
              onRefresh: passViewModel.loadAvailablePasses,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _buildTopBanner(),
                  const SizedBox(height: AppSpacing.huge),
                  if (passViewModel.state == AppState.loading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ...PassType.values.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _PlanCard(
                          passType: type,
                          isSelected: passViewModel.selectedPassType == type,
                          onSelect: () => passViewModel.selectPassType(type),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _purchaseSelectedPlan(context),
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text('Purchase Selected Plan'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.huge),
                  _buildCurrentPassSection(passViewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick a pass that fits your ride routine and unlock seamless booking.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPassSection(PassViewModel passViewModel) {
    final activePass = passViewModel.activePass;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Current Plan', style: AppTextStyles.h5),
            const SizedBox(height: AppSpacing.sm),
            if (activePass == null)
              Text(
                'No active plan yet.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else ...[
              Text(
                activePass.type.displayName,
                style: AppTextStyles.h4.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Remaining ${activePass.remainingDays} day(s)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseSelectedPlan(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final passViewModel = context.read<PassViewModel>();
    final success = await passViewModel.purchaseSelectedPass();

    if (!mounted) {
      return;
    }

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Pass purchased successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    final message = passViewModel.errorMessage ?? 'Purchase failed';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.passType,
    required this.isSelected,
    required this.onSelect,
  });

  final PassType passType;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(passType.displayName, style: AppTextStyles.h5),
                Text(
                  '\$${passType.price.toStringAsFixed(2)}',
                  style: AppTextStyles.h4.copyWith(
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${passType.durationDays} day(s)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.grey500,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  isSelected ? 'Selected' : 'Tap to select',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.grey600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
