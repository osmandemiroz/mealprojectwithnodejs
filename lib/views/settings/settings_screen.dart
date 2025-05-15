// ignore_for_file: inference_failure_on_instance_creation, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../services/auth_service.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // App version - hardcoded for now, but could be read from a config file later
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    // Get the auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      children: [
        // Account Section
        _buildSection(
          title: 'Account',
          children: [
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'Manage your personal information',
              onTap: () {
                // Navigate to profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacing24),

        // App Section
        _buildSection(
          title: 'App',
          children: [
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Learn more about the app',
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacing32),

        // Sign Out Button
        Center(
          child: TextButton(
            onPressed: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              // If confirmed, sign out and navigate to login
              // ignore: use_if_null_to_convert_nulls_to_bools
              if (confirm == true) {
                await authService.logout();
                if (context.mounted) {
                  await Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
                vertical: AppTheme.spacing12,
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ),

        const SizedBox(height: AppTheme.spacing16),

        // App Version
        Center(
          child: Text(
            'Version $appVersion',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacing32),
      ],
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // App Icon
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        Color(0xFF5D8D9C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ).animate().fadeIn().scale(),

              // App Name and Version
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Meal Planner',
                  style: AppTheme.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn().slideY(),

              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Version $appVersion',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ).animate().fadeIn().slideY(),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Divider(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),

              // App Information
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        title: 'About',
                        content:
                            'Meal Planner is a modern nutrition app designed to help you achieve your health and fitness goals through personalized meal planning and goal tracking.',
                      ),

                      _buildInfoSection(
                        title: 'Features',
                        content:
                            '• Create personalized nutrition goals\n• Track your daily meals and nutrition\n• Browse and save recipes\n• Monitor your progress\n• Plan your weekly meals',
                      ),

                      _buildInfoSection(
                        title: 'Built With',
                        content:
                            "Flutter and Node.js with a focus on beautiful design following Apple's Human Interface Guidelines.",
                      ),

                      _buildInfoSection(
                        title: 'Credits',
                        content: 'Icons by Material Design\nFonts by SF Pro',
                      ),

                      const SizedBox(height: 16),

                      // Copyright
                      Center(
                        child: Text(
                          '© ${DateTime.now().year} Meal Planner. All rights reserved.',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTheme.bodyMedium.copyWith(
              height: 1.5,
            ),
          ).animate().fadeIn().slideX(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacing16,
            bottom: AppTheme.spacing8,
          ),
          child: Text(
            title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge,
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTheme.spacing16),
                trailing,
              ],
              const SizedBox(width: AppTheme.spacing8),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
