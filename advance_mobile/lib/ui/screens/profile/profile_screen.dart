import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import 'view_model/profile_viewmodel.dart';
import 'widgets/activity_graph.dart';
import 'widgets/subscription_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == AppState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == AppState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = viewModel.user;

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Profile Header
                  _buildHeader(user),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subscription Section
                        const _SectionTitle(title: 'YOUR SUBSCRIPTION'),
                        const SizedBox(height: 8),
                        SubscriptionCard(activePass: viewModel.activePass),
                        const SizedBox(height: 24),

                        // Activity Section
                        const _SectionTitle(title: 'YOUR ACTIVITY'),
                        const SizedBox(height: 8),
                        ActivityGraph(
                          totalRides: viewModel.totalRides,
                          totalDistance: viewModel.totalDistance,
                          totalDurationMinutes: viewModel.totalDurationMinutes,
                        ),
                        const SizedBox(height: 24),

                        // Settings Sections (Lean)
                        const _SectionTitle(title: 'SETTINGS'),
                        const SizedBox(height: 8),
                        _buildSettingsCard([
                          _SettingsTile(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit Profile coming soon')),
                              );
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            trailing: Switch(
                              value: false, // Static for now as requested to avoid too many changes
                              onChanged: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dark Mode integration in progress')),
                                );
                              },
                            ),
                          ),
                        ]),
                        const SizedBox(height: 32),

                        // Version
                        Center(
                          child: Text(
                            'App Version 1.0.0',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 50, color: Colors.blue),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'John Doe',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'john@example.com',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
