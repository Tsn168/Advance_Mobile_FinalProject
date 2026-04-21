import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/pass/pass.dart' as model_pass;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
// import '../../../widgets/subscription/subscription_card.dart';
import '../../widgets/pass_card.dart';
import 'view_model/pass_viewmodel.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  static const List<_PassOption> _passOptions = [
    _PassOption(
      type: model_pass.PassType.day,
      badgeText: 'QUICK START',
      badgeColor: Color(0xFF2196F3),
      description:
          '24 hours validity. Perfect for visitors and spontaneous city exploration.',
      displayPrice: 5.00,
    ),
    _PassOption(
      type: model_pass.PassType.monthly,
      badgeText: 'BEST VALUE',
      badgeColor: Color(0xFFFF9800),
      description:
          '30 days validity. Unlimited 60-minute rides for daily commuters and locals.',
      displayPrice: 25.00,
    ),
    _PassOption(
      type: model_pass.PassType.annual,
      badgeText: 'BEST IDEA',
      badgeColor: Color(0xFFFFC107),
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
            leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
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
                  child: Icon(Icons.person, size: 18, color: Color(0xFF2196F3)),
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

                // Active Pass Section (if any)
                if (hasActivePass) ...[
                  _buildCurrentPassSection(passViewModel),
                  const SizedBox(height: 24),
                ],

                // Grid/List of Pass Options
                ..._passOptions.map((option) {
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
                      onPressed: () =>
                          _showCurrentPlanDetails(context, passViewModel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF673AB7),
                        side: const BorderSide(
                          color: Color(0xFF673AB7),
                          width: 2,
                        ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Subscription',
                    style: TextStyle(fontSize: 14, color: AppColors.grey600),
                  ),
                  Text(
                    activePass?.type.displayName ?? 'Standard Pass',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (activePass != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expires in ${activePass.expiryDate.difference(DateTime.now()).inDays} days',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePass(
    BuildContext context,
    model_pass.PassType type,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final passViewModel = context.read<PassViewModel>();

    passViewModel.selectPassType(type);
    final success = await passViewModel.purchaseSelectedPass();

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('${type.displayName} purchased successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(passViewModel.errorMessage ?? 'Purchase failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCurrentPlanDetails(
    BuildContext context,
    PassViewModel passViewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final activePass = passViewModel.activePass;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Type', activePass?.type.displayName ?? 'N/A'),
              _buildDetailRow(
                'Purchased',
                activePass?.startDate.toString().split(' ')[0] ?? 'N/A',
              ),
              _buildDetailRow(
                'Expiry',
                activePass?.expiryDate.toString().split(' ')[0] ?? 'N/A',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PassOption {
  final model_pass.PassType type;
  final String badgeText;
  final Color badgeColor;
  final String description;
  final double displayPrice;

  const _PassOption({
    required this.type,
    required this.badgeText,
    required this.badgeColor,
    required this.description,
    required this.displayPrice,
  });
}
