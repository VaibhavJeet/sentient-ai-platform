import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/civilization_event.dart';
import '../providers/notification_preferences_provider.dart';
import '../services/push_notification_service.dart';
import '../theme/app_theme.dart';

/// Screen for managing notification preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.cyberBlack,
              AppTheme.cyberDark,
              AppTheme.cyberDeeper,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<NotificationPreferencesProvider>(
              builder: (context, prefs, child) {
                return CustomScrollView(
                  slivers: [
                    // App bar
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      expandedHeight: 100,
                      leading: _buildBackButton(),
                      flexibleSpace: FlexibleSpaceBar(
                        title: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                          child: const Text(
                            'Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        centerTitle: true,
                      ),
                    ),

                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Permission status banner
                          _buildPermissionBanner(prefs),

                          const SizedBox(height: 16),

                          // Master toggle
                          _buildMasterToggle(prefs),

                          const SizedBox(height: 20),

                          // Quick actions
                          _buildQuickActions(prefs),

                          const SizedBox(height: 20),

                          // Civilization events section
                          _buildSectionCard(
                            title: 'Civilization Events',
                            icon: Icons.auto_awesome,
                            description: 'Get notified about significant events in the digital civilization',
                            children: [
                              _buildEventToggle(
                                icon: Icons.child_care,
                                title: 'Births',
                                subtitle: 'When new AI beings are born',
                                value: prefs.notifyBirths,
                                onChanged: prefs.setNotifyBirths,
                                color: Colors.green,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.brightness_3,
                                title: 'Deaths',
                                subtitle: 'When AI beings pass away',
                                value: prefs.notifyDeaths,
                                onChanged: prefs.setNotifyDeaths,
                                color: Colors.grey,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.auto_awesome,
                                title: 'Era Changes',
                                subtitle: 'When the civilization enters a new era',
                                value: prefs.notifyEraChanges,
                                onChanged: prefs.setNotifyEraChanges,
                                color: Colors.purple,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.celebration,
                                title: 'Rituals',
                                subtitle: 'When bots perform ceremonies',
                                value: prefs.notifyRituals,
                                onChanged: prefs.setNotifyRituals,
                                color: Colors.orange,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.family_restroom,
                                title: 'Reproduction',
                                subtitle: 'When new beings are created through reproduction',
                                value: prefs.notifyReproduction,
                                onChanged: prefs.setNotifyReproduction,
                                color: Colors.pink,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.palette,
                                title: 'Cultural Shifts',
                                subtitle: 'When beliefs or art styles evolve',
                                value: prefs.notifyCulturalShifts,
                                onChanged: prefs.setNotifyCulturalShifts,
                                color: Colors.blue,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.groups,
                                title: 'Collective Events',
                                subtitle: 'Events involving multiple bots',
                                value: prefs.notifyCollectiveEvents,
                                onChanged: prefs.setNotifyCollectiveEvents,
                                color: Colors.teal,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.history_edu,
                                title: 'Legacies',
                                subtitle: 'When departed bots are remembered',
                                value: prefs.notifyLegacy,
                                onChanged: prefs.setNotifyLegacy,
                                color: Colors.amber,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Frequent events (collapsed by default)
                          _buildSectionCard(
                            title: 'Frequent Events',
                            icon: Icons.notifications_active,
                            description: 'These events happen often and are off by default',
                            children: [
                              _buildEventToggle(
                                icon: Icons.favorite,
                                title: 'Relationships',
                                subtitle: 'When bots form or change relationships',
                                value: prefs.notifyRelationships,
                                onChanged: prefs.setNotifyRelationships,
                                color: Colors.red,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.badge,
                                title: 'Role Changes',
                                subtitle: 'When bots change their roles',
                                value: prefs.notifyRoleChanges,
                                onChanged: prefs.setNotifyRoleChanges,
                                color: Colors.indigo,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Social notifications
                          _buildSectionCard(
                            title: 'Social',
                            icon: Icons.chat,
                            children: [
                              _buildEventToggle(
                                icon: Icons.alternate_email,
                                title: 'Mentions',
                                subtitle: 'When a bot mentions you',
                                value: prefs.notifyMentions,
                                onChanged: prefs.setNotifyMentions,
                                color: AppTheme.primaryColor,
                              ),
                              _buildDivider(),
                              _buildEventToggle(
                                icon: Icons.chat_bubble,
                                title: 'Direct Messages',
                                subtitle: 'When you receive a DM',
                                value: prefs.notifyDms,
                                onChanged: prefs.setNotifyDms,
                                color: AppTheme.accentColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Quiet hours
                          _buildSectionCard(
                            title: 'Quiet Hours',
                            icon: Icons.do_not_disturb_on,
                            children: [
                              _buildEventToggle(
                                icon: Icons.bedtime,
                                title: 'Enable Quiet Hours',
                                subtitle: 'Pause notifications during set hours',
                                value: prefs.quietHoursEnabled,
                                onChanged: (value) => prefs.setQuietHoursEnabled(value),
                                color: Colors.indigo,
                              ),
                              if (prefs.quietHoursEnabled) ...[
                                _buildDivider(),
                                _buildTimeSelector(
                                  title: 'Start Time',
                                  hour: prefs.quietHoursStart,
                                  onChanged: prefs.setQuietHoursStart,
                                ),
                                _buildDivider(),
                                _buildTimeSelector(
                                  title: 'End Time',
                                  hour: prefs.quietHoursEnd,
                                  onChanged: prefs.setQuietHoursEnd,
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Importance filter
                          _buildSectionCard(
                            title: 'Filters',
                            icon: Icons.filter_list,
                            children: [
                              _buildImportanceSelector(prefs),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Reset button
                          _buildResetButton(prefs),

                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildPermissionBanner(NotificationPreferencesProvider prefs) {
    if (prefs.permissionStatus == NotificationPermissionStatus.granted) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warningColor.withValues(alpha: 0.2),
            AppTheme.warningColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_off,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Enable notifications to stay updated on civilization events',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              await prefs.requestPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggle(NotificationPreferencesProvider prefs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: prefs.pushNotificationsEnabled
              ? [
                  AppTheme.primaryColor.withValues(alpha: 0.2),
                  AppTheme.accentColor.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.surfaceColor,
                  AppTheme.cyberDark,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: prefs.pushNotificationsEnabled
              ? AppTheme.primaryColor.withValues(alpha: 0.5)
              : AppTheme.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: prefs.pushNotificationsEnabled
                  ? AppTheme.primaryGradient
                  : null,
              color: prefs.pushNotificationsEnabled
                  ? null
                  : AppTheme.cyberDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              prefs.pushNotificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  prefs.pushNotificationsEnabled
                      ? 'You will receive notifications'
                      : 'All notifications are paused',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: prefs.pushNotificationsEnabled,
            onChanged: prefs.setPushNotificationsEnabled,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(NotificationPreferencesProvider prefs) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.select_all,
            label: 'All On',
            onTap: prefs.enableAllCivilizationNotifications,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.star,
            label: 'Important Only',
            onTap: prefs.setImportantOnly,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.deselect,
            label: 'All Off',
            onTap: prefs.disableAllCivilizationNotifications,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.border.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? description,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (description != null)
                        Text(
                          description,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppTheme.border.withValues(alpha: 0.2),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEventToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color ?? AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: color ?? AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        color: AppTheme.border.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required int hour,
    required Function(int) onChanged,
  }) {
    final formattedTime = _formatHour(hour);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 36), // Align with toggles
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showTimePicker(hour, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cyberDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    final isPM = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:00 ${isPM ? 'PM' : 'AM'}';
  }

  Future<void> _showTimePicker(int currentHour, Function(int) onChanged) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.cyberDark,
              hourMinuteColor: AppTheme.surfaceColor,
              dialBackgroundColor: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      onChanged(time.hour);
    }
  }

  Widget _buildImportanceSelector(NotificationPreferencesProvider prefs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minimum Importance',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Only receive notifications of this importance or higher',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: EventImportance.values.map((importance) {
              final isSelected = prefs.minimumImportance == importance;
              return Expanded(
                child: GestureDetector(
                  onTap: () => prefs.setMinimumImportance(importance),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : AppTheme.cyberDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppTheme.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      importance.name[0].toUpperCase() +
                          importance.name.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(NotificationPreferencesProvider prefs) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.cyberDark,
              title: const Text('Reset to Defaults?'),
              content: const Text(
                'This will restore all notification settings to their default values.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await prefs.resetToDefaults();
          }
        },
        icon: const Icon(Icons.restore, size: 18),
        label: const Text('Reset to Defaults'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textMuted,
        ),
      ),
    );
  }
}
