import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'language_settings_screen.dart';
import '../constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<User?>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // Navigate to edit profile
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const EditProfileScreen(),
              //   ),
              // );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          const SizedBox(height: 24),
          
          // Preferences Section
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                // TODO: Implement theme change
                // AppTheme.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              });
            },
          ),
          _buildListTile(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            trailing: Text(
              _language,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () async {
              final selectedLanguage = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
              
              if (selectedLanguage != null) {
                setState(() {
                  _language = selectedLanguage;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none),
            title: const Text('Push Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Update notification preferences
              });
            },
          ),
          _buildListTile(
            context,
            icon: Icons.notification_important_outlined,
            title: 'Notification Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Support Section
          _buildSectionHeader('Support'),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {
              // Open help center
            },
          ),
          _buildListTile(
            context,
            icon: Icons.email_outlined,
            title: 'Contact Us',
            onTap: () {
              // Open contact form
            },
          ),
          _buildListTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // Show terms of service
            },
          ),
          _buildListTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Show privacy policy
            },
          ),
          const SizedBox(height: 32),
          
          // Sign Out Button
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await context.read<AuthService>().signOut();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // App Version
          Center(
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      minLeadingWidth: 24,
    );
  }
}
