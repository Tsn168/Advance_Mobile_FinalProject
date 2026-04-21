import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/pass/pass.dart';
import '../../widgets/pass_card.dart';
import '../../widgets/pass_info_card.dart';
import '../../theme/app_colors.dart';
import 'view_model/pass_viewmodel.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  static const List<_PassOption> _passOptions = [
    _PassOption(
      type: PassType.day,
      badgeText: 'QUICK START',
      badgeColor: AppColors.teal,
      description:
          '24 hours validity. Perfect for visitors and spontaneous city exploration.',
      displayPrice: 5.00,
    ),
    _PassOption(
      type: PassType.monthly,
      badgeText: 'BEST VALUE',
      badgeColor: AppColors.blue,
      description:
          '30 days validity. Unlimited 60-minute rides for daily commuters and locals.',
      displayPrice: 25.00,
    ),
    _PassOption(
      type: PassType.annual,
      badgeText: 'BEST IDEA',
      badgeColor: AppColors.lightBlue,
      description:
          '365 days validity. The ultimate commitment to green mobility and health.',
      displayPrice: 150.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PassViewModel>(
      builder: (context, passViewModel, _) {
        final hasActivePass = passViewModel.hasActivePass;

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
             actions: const [
               Padding(
                 padding: EdgeInsets.only(right: 12),
                 child: CircleAvatar(
                   radius: 16,
                   backgroundColor: Color(0xFFE3F2FD),
                   child: Icon(Icons.person, size: 18, color: AppColors.blue),
                 ),
               ),
             ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                passViewModel.loadAvailablePasses(),
                passViewModel.loadUserPasses(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Manage your subscription',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fuel your momentum with flexible access to our fleet.',
                  style: TextStyle(color: Color(0xFF607D8B), fontSize: 14),
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
                  const SizedBox(height: 16),
                ],
                if (passViewModel.state == AppState.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ..._passOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PassCard(
                      passType: option.type,
                      badgeText: option.badgeText,
                      badgeColor: option.badgeColor,
                      description: option.description,
                      displayPrice: option.displayPrice,
                      isSelected: passViewModel.selectedPassType == option.type,
                      isChooseEnabled: !hasActivePass,
                      onChoose: () => _purchasePass(context, option.type),
                    ),
                  );
                }),
                if (hasActivePass)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showCurrentPlanDetails(context, passViewModel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF673AB7),
                        side: const BorderSide(color: Color(0xFF673AB7), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'MANAGE YOUR CURRENT PLAN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (passViewModel.state == AppState.error &&
                    passViewModel.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    passViewModel.errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
    passViewModel.selectPassType(passType);
    final success = await passViewModel.purchaseSelectedPass();

    if (!mounted) {
      return;
    }

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('${passType.displayName} purchased successfully'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      return;
    }

    final message = passViewModel.errorMessage ?? 'Purchase failed';
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFD32F2F)),
    );
  }
}
