import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/pass/pass.dart' as model_pass;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../../widgets/subscription/subscription_card.dart';
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
          body: RefreshIndicator(
            onRefresh: passViewModel.loadAvailablePasses,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const Text(
                  'Choose Your Plan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'All plan logic is managed by PassViewModel (MVVM).',
                  style: TextStyle(color: AppColors.grey600, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (passViewModel.state == AppState.loading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ...model_pass.PassType.values.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: SubscriptionCard(
                        passType: _mapPassType(type),
                        price: type.price,
                        originalPrice: '',
                        description: 'Enjoy unlimited rides for ${type.durationDays} day(s).',
                        isActive: passViewModel.selectedPassType == type,
                        isPopular: type == model_pass.PassType.monthly,
                        onChoose: () => passViewModel.selectPassType(type),
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
        );
      },
    );
  }

  Widget _buildCurrentPassSection(PassViewModel passViewModel) {
    final activePass = passViewModel.activePass;

    return Card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Current Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (activePass == null)
              const Text('No active plan yet.')
            else ...[
              Text(activePass.type.displayName),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Remaining ${activePass.remainingDays} day(s)',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PassType _mapPassType(model_pass.PassType type) {
    switch (type) {
      case model_pass.PassType.monthly:
        return PassType.monthly;
      case model_pass.PassType.annual:
        return PassType.annual;
      default:
        return PassType.day;
    }
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
