import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  bool _smsNotificationsEnabled = false;
  bool _eventRemindersEnabled = true;
  bool _betUpdatesEnabled = true;
  bool _promotionalOffersEnabled = false;
  bool _newsletterEnabled = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    // In a real app, load these from Firestore or local storage
    setState(() {
      _pushNotificationsEnabled = true;
      _emailNotificationsEnabled = false;
      _smsNotificationsEnabled = false;
      _eventRemindersEnabled = true;
      _betUpdatesEnabled = true;
      _promotionalOffersEnabled = false;
      _newsletterEnabled = false;
    });
  }

  Future<void> _updateNotificationSettings() async {
    try {
      // Update in Firestore
      await _firestoreService.updateNotificationSettings(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        settings: {
          'pushNotifications': _pushNotificationsEnabled,
          'emailNotifications': _emailNotificationsEnabled,
          'smsNotifications': _smsNotificationsEnabled,
          'eventReminders': _eventRemindersEnabled,
          'betUpdates': _betUpdatesEnabled,
          'promotionalOffers': _promotionalOffersEnabled,
          'newsletter': _newsletterEnabled,
        },
      );

      // Update FCM token based on push notification settings
      if (_pushNotificationsEnabled) {
        await _firebaseMessaging.requestPermission();
        await _firebaseMessaging.getToken();
      } else {
        // Unsubscribe from all topics or disable FCM
        await _firebaseMessaging.deleteToken();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _updateNotificationSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Channels
            _buildSectionHeader('Notification Channels'),
            _buildSwitchListTile(
              title: 'Push Notifications',
              subtitle: 'Receive app notifications',
              value: _pushNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _pushNotificationsEnabled = value;
                });
              },
              icon: Icons.notifications_none,
            ),
            _buildSwitchListTile(
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _emailNotificationsEnabled = value;
                });
              },
              icon: Icons.email_outlined,
            ),
            _buildSwitchListTile(
              title: 'SMS Notifications',
              subtitle: 'Receive notifications via SMS',
              value: _smsNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _smsNotificationsEnabled = value;
                });
              },
              icon: Icons.sms_outlined,
            ),
            const SizedBox(height: 24),

            // Notification Types
            _buildSectionHeader('Notification Types'),
            _buildSwitchListTile(
              title: 'Event Reminders',
              subtitle: 'Get reminders for upcoming events',
              value: _eventRemindersEnabled,
              onChanged: (value) {
                setState(() {
                  _eventRemindersEnabled = value;
                });
              },
              icon: Icons.event_available_outlined,
            ),
            _buildSwitchListTile(
              title: 'Bet Updates',
              subtitle: 'Get updates on your active bets',
              value: _betUpdatesEnabled,
              onChanged: (value) {
                setState(() {
                  _betUpdatesEnabled = value;
                });
              },
              icon: Icons.attach_money_outlined,
            ),
            _buildSwitchListTile(
              title: 'Promotional Offers',
              subtitle: 'Receive special offers and promotions',
              value: _promotionalOffersEnabled,
              onChanged: (value) {
                setState(() {
                  _promotionalOffersEnabled = value;
                });
              },
              icon: Icons.local_offer_outlined,
            ),
            _buildSwitchListTile(
              title: 'Newsletter',
              subtitle: 'Weekly digest and news',
              value: _newsletterEnabled,
              onChanged: (value) {
                setState(() {
                  _newsletterEnabled = value;
                });
              },
              icon: Icons.article_outlined,
            ),
            const SizedBox(height: 32),

            // Notification Preferences
            _buildSectionHeader('Notification Preferences'),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Sound'),
              subtitle: const Text('Default notification sound'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show sound options
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.vibration_outlined),
              title: const Text('Vibration'),
              subtitle: const Text('Default vibration pattern'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show vibration options
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Quiet Hours'),
              subtitle: const Text('Set do not disturb hours'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show quiet hours settings
              },
            ),
            const SizedBox(height: 24),

            // Notification Preview
            _buildSectionHeader('Preview'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SalesBets',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Now',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New event: Team A vs Team B is starting soon!',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateNotificationSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 24,
    );
  }
}
