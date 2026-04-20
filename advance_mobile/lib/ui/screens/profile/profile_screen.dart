import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.18),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'John Doe',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'john@example.com',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Member since April 2026',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.huge),

              _SettingsSection(
                title: 'Account',
                items: [
                  _SettingsTile(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.email,
                    title: 'Email Verification',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.huge),

              _SettingsSection(
                title: 'Payment & Subscription',
                items: [
                  _SettingsTile(
                    icon: Icons.credit_card,
                    title: 'Payment Methods',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.receipt,
                    title: 'Billing History',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.card_membership,
                    title: 'Subscription',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.huge),

              _SettingsSection(
                title: 'Preferences',
                items: [
                  _SettingsTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.huge),

              _SettingsSection(
                title: 'Support',
                items: [
                  _SettingsTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.bug_report,
                    title: 'Report Issue',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info,
                    title: 'About App',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.huge),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'App Version 1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsTile> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey600,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(child: Column(children: items)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryDark, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
      onTap: onTap,
    );
  }
}
