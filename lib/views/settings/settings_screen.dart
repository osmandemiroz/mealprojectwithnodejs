import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                // TODO: Navigate to profile settings
              },
            ),
            _buildSettingsTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Configure your notification preferences',
              onTap: () {
                // TODO: Navigate to notification settings
              },
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacing24),

        // Preferences Section
        _buildSection(
          title: 'Preferences',
          children: [
            _buildSettingsTile(
              icon: Icons.restaurant_menu,
              title: 'Dietary Preferences',
              subtitle: 'Set your dietary restrictions and preferences',
              onTap: () {
                // TODO: Navigate to dietary preferences
              },
            ),
            _buildSettingsTile(
              icon: Icons.people_outline,
              title: 'Household Size',
              subtitle: 'Adjust serving sizes for your household',
              onTap: () {
                // TODO: Navigate to household settings
              },
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Change app language',
              trailing: const Text(
                'English',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              onTap: () {
                // TODO: Show language picker
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
                // TODO: Show about dialog
              },
            ),
            _buildSettingsTile(
              icon: Icons.star_border,
              title: 'Rate App',
              subtitle: 'Rate us on the App Store',
              onTap: () {
                // TODO: Open App Store
              },
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacing32),

        // Sign Out Button
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: Implement sign out
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
            'Version 1.0.0',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacing32),
      ],
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
