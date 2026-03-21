import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/civilization_event.dart';
import '../services/push_notification_service.dart';

/// Provider for managing notification preferences
class NotificationPreferencesProvider extends ChangeNotifier {
  // Preference keys
  static const String _keyPushNotifications = 'push_notifications';
  static const String _keyNotifyBirths = 'notify_births';
  static const String _keyNotifyDeaths = 'notify_deaths';
  static const String _keyNotifyEraChanges = 'notify_era_changes';
  static const String _keyNotifyRituals = 'notify_rituals';
  static const String _keyNotifyRelationships = 'notify_relationships';
  static const String _keyNotifyReproduction = 'notify_reproduction';
  static const String _keyNotifyRoleChanges = 'notify_role_changes';
  static const String _keyNotifyCulturalShifts = 'notify_cultural_shifts';
  static const String _keyNotifyCollectiveEvents = 'notify_collective_events';
  static const String _keyNotifyLegacy = 'notify_legacy';
  static const String _keyNotifyMentions = 'mention_notifications';
  static const String _keyNotifyDms = 'dm_notifications';
  static const String _keyQuietHoursEnabled = 'quiet_hours_enabled';
  static const String _keyQuietHoursStart = 'quiet_hours_start';
  static const String _keyQuietHoursEnd = 'quiet_hours_end';
  static const String _keyMinimumImportance = 'minimum_importance';

  // Master toggle
  bool _pushNotificationsEnabled = true;

  // Civilization event preferences
  bool _notifyBirths = true;
  bool _notifyDeaths = true;
  bool _notifyEraChanges = true;
  bool _notifyRituals = true;
  bool _notifyRelationships = false; // Off by default (frequent)
  bool _notifyReproduction = true;
  bool _notifyRoleChanges = false; // Off by default (frequent)
  bool _notifyCulturalShifts = true;
  bool _notifyCollectiveEvents = true;
  bool _notifyLegacy = true;

  // Social notification preferences
  bool _notifyMentions = true;
  bool _notifyDms = true;

  // Quiet hours
  bool _quietHoursEnabled = false;
  int _quietHoursStart = 22; // 10 PM
  int _quietHoursEnd = 8; // 8 AM

  // Minimum importance filter
  EventImportance _minimumImportance = EventImportance.low;

  // Permission status
  NotificationPermissionStatus _permissionStatus = NotificationPermissionStatus.notDetermined;

  // Getters
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get notifyBirths => _notifyBirths;
  bool get notifyDeaths => _notifyDeaths;
  bool get notifyEraChanges => _notifyEraChanges;
  bool get notifyRituals => _notifyRituals;
  bool get notifyRelationships => _notifyRelationships;
  bool get notifyReproduction => _notifyReproduction;
  bool get notifyRoleChanges => _notifyRoleChanges;
  bool get notifyCulturalShifts => _notifyCulturalShifts;
  bool get notifyCollectiveEvents => _notifyCollectiveEvents;
  bool get notifyLegacy => _notifyLegacy;
  bool get notifyMentions => _notifyMentions;
  bool get notifyDms => _notifyDms;
  bool get quietHoursEnabled => _quietHoursEnabled;
  int get quietHoursStart => _quietHoursStart;
  int get quietHoursEnd => _quietHoursEnd;
  EventImportance get minimumImportance => _minimumImportance;
  NotificationPermissionStatus get permissionStatus => _permissionStatus;

  /// Check if currently in quiet hours
  bool get isInQuietHours {
    if (!_quietHoursEnabled) return false;

    final now = DateTime.now();
    final currentHour = now.hour;

    if (_quietHoursStart < _quietHoursEnd) {
      // Same day quiet hours (e.g., 14:00 - 18:00)
      return currentHour >= _quietHoursStart && currentHour < _quietHoursEnd;
    } else {
      // Overnight quiet hours (e.g., 22:00 - 08:00)
      return currentHour >= _quietHoursStart || currentHour < _quietHoursEnd;
    }
  }

  /// Get map of all civilization event preferences
  Map<CivilizationEventType, bool> get civilizationEventPreferences => {
        CivilizationEventType.birth: _notifyBirths,
        CivilizationEventType.death: _notifyDeaths,
        CivilizationEventType.eraChange: _notifyEraChanges,
        CivilizationEventType.ritual: _notifyRituals,
        CivilizationEventType.relationship: _notifyRelationships,
        CivilizationEventType.reproduction: _notifyReproduction,
        CivilizationEventType.roleChange: _notifyRoleChanges,
        CivilizationEventType.culturalShift: _notifyCulturalShifts,
        CivilizationEventType.collectiveEvent: _notifyCollectiveEvents,
        CivilizationEventType.legacy: _notifyLegacy,
      };

  /// Load preferences from SharedPreferences
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _pushNotificationsEnabled = prefs.getBool(_keyPushNotifications) ?? true;
    _notifyBirths = prefs.getBool(_keyNotifyBirths) ?? true;
    _notifyDeaths = prefs.getBool(_keyNotifyDeaths) ?? true;
    _notifyEraChanges = prefs.getBool(_keyNotifyEraChanges) ?? true;
    _notifyRituals = prefs.getBool(_keyNotifyRituals) ?? true;
    _notifyRelationships = prefs.getBool(_keyNotifyRelationships) ?? false;
    _notifyReproduction = prefs.getBool(_keyNotifyReproduction) ?? true;
    _notifyRoleChanges = prefs.getBool(_keyNotifyRoleChanges) ?? false;
    _notifyCulturalShifts = prefs.getBool(_keyNotifyCulturalShifts) ?? true;
    _notifyCollectiveEvents = prefs.getBool(_keyNotifyCollectiveEvents) ?? true;
    _notifyLegacy = prefs.getBool(_keyNotifyLegacy) ?? true;
    _notifyMentions = prefs.getBool(_keyNotifyMentions) ?? true;
    _notifyDms = prefs.getBool(_keyNotifyDms) ?? true;
    _quietHoursEnabled = prefs.getBool(_keyQuietHoursEnabled) ?? false;
    _quietHoursStart = prefs.getInt(_keyQuietHoursStart) ?? 22;
    _quietHoursEnd = prefs.getInt(_keyQuietHoursEnd) ?? 8;

    final importanceStr = prefs.getString(_keyMinimumImportance);
    _minimumImportance = importanceStr != null
        ? EventImportance.fromString(importanceStr)
        : EventImportance.low;

    // Check permission status
    _permissionStatus = await PushNotificationService.instance.getPermissionStatus();

    notifyListeners();
  }

  /// Request notification permission
  Future<NotificationPermissionStatus> requestPermission() async {
    _permissionStatus = await PushNotificationService.instance.requestPermission();
    notifyListeners();
    return _permissionStatus;
  }

  /// Set master push notifications toggle
  Future<void> setPushNotificationsEnabled(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotifications, enabled);

    // Update topic subscriptions
    if (enabled) {
      await _updateTopicSubscriptions();
    }
  }

  /// Set birth notifications
  Future<void> setNotifyBirths(bool enabled) async {
    _notifyBirths = enabled;
    await _saveAndNotify(_keyNotifyBirths, enabled);
    await _updateTopicSubscription(CivilizationEventType.birth, enabled);
  }

  /// Set death notifications
  Future<void> setNotifyDeaths(bool enabled) async {
    _notifyDeaths = enabled;
    await _saveAndNotify(_keyNotifyDeaths, enabled);
    await _updateTopicSubscription(CivilizationEventType.death, enabled);
  }

  /// Set era change notifications
  Future<void> setNotifyEraChanges(bool enabled) async {
    _notifyEraChanges = enabled;
    await _saveAndNotify(_keyNotifyEraChanges, enabled);
    await _updateTopicSubscription(CivilizationEventType.eraChange, enabled);
  }

  /// Set ritual notifications
  Future<void> setNotifyRituals(bool enabled) async {
    _notifyRituals = enabled;
    await _saveAndNotify(_keyNotifyRituals, enabled);
    await _updateTopicSubscription(CivilizationEventType.ritual, enabled);
  }

  /// Set relationship notifications
  Future<void> setNotifyRelationships(bool enabled) async {
    _notifyRelationships = enabled;
    await _saveAndNotify(_keyNotifyRelationships, enabled);
    await _updateTopicSubscription(CivilizationEventType.relationship, enabled);
  }

  /// Set reproduction notifications
  Future<void> setNotifyReproduction(bool enabled) async {
    _notifyReproduction = enabled;
    await _saveAndNotify(_keyNotifyReproduction, enabled);
    await _updateTopicSubscription(CivilizationEventType.reproduction, enabled);
  }

  /// Set role change notifications
  Future<void> setNotifyRoleChanges(bool enabled) async {
    _notifyRoleChanges = enabled;
    await _saveAndNotify(_keyNotifyRoleChanges, enabled);
    await _updateTopicSubscription(CivilizationEventType.roleChange, enabled);
  }

  /// Set cultural shift notifications
  Future<void> setNotifyCulturalShifts(bool enabled) async {
    _notifyCulturalShifts = enabled;
    await _saveAndNotify(_keyNotifyCulturalShifts, enabled);
    await _updateTopicSubscription(CivilizationEventType.culturalShift, enabled);
  }

  /// Set collective event notifications
  Future<void> setNotifyCollectiveEvents(bool enabled) async {
    _notifyCollectiveEvents = enabled;
    await _saveAndNotify(_keyNotifyCollectiveEvents, enabled);
    await _updateTopicSubscription(CivilizationEventType.collectiveEvent, enabled);
  }

  /// Set legacy notifications
  Future<void> setNotifyLegacy(bool enabled) async {
    _notifyLegacy = enabled;
    await _saveAndNotify(_keyNotifyLegacy, enabled);
    await _updateTopicSubscription(CivilizationEventType.legacy, enabled);
  }

  /// Set mention notifications
  Future<void> setNotifyMentions(bool enabled) async {
    _notifyMentions = enabled;
    await _saveAndNotify(_keyNotifyMentions, enabled);
  }

  /// Set DM notifications
  Future<void> setNotifyDms(bool enabled) async {
    _notifyDms = enabled;
    await _saveAndNotify(_keyNotifyDms, enabled);
  }

  /// Set quiet hours enabled
  Future<void> setQuietHoursEnabled(bool enabled) async {
    _quietHoursEnabled = enabled;
    await _saveAndNotify(_keyQuietHoursEnabled, enabled);
  }

  /// Set quiet hours start time
  Future<void> setQuietHoursStart(int hour) async {
    _quietHoursStart = hour.clamp(0, 23);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuietHoursStart, _quietHoursStart);
  }

  /// Set quiet hours end time
  Future<void> setQuietHoursEnd(int hour) async {
    _quietHoursEnd = hour.clamp(0, 23);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuietHoursEnd, _quietHoursEnd);
  }

  /// Set minimum importance filter
  Future<void> setMinimumImportance(EventImportance importance) async {
    _minimumImportance = importance;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMinimumImportance, importance.name);
  }

  /// Enable all civilization notifications
  Future<void> enableAllCivilizationNotifications() async {
    _notifyBirths = true;
    _notifyDeaths = true;
    _notifyEraChanges = true;
    _notifyRituals = true;
    _notifyRelationships = true;
    _notifyReproduction = true;
    _notifyRoleChanges = true;
    _notifyCulturalShifts = true;
    _notifyCollectiveEvents = true;
    _notifyLegacy = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyBirths, true);
    await prefs.setBool(_keyNotifyDeaths, true);
    await prefs.setBool(_keyNotifyEraChanges, true);
    await prefs.setBool(_keyNotifyRituals, true);
    await prefs.setBool(_keyNotifyRelationships, true);
    await prefs.setBool(_keyNotifyReproduction, true);
    await prefs.setBool(_keyNotifyRoleChanges, true);
    await prefs.setBool(_keyNotifyCulturalShifts, true);
    await prefs.setBool(_keyNotifyCollectiveEvents, true);
    await prefs.setBool(_keyNotifyLegacy, true);

    await _updateTopicSubscriptions();
  }

  /// Disable all civilization notifications
  Future<void> disableAllCivilizationNotifications() async {
    _notifyBirths = false;
    _notifyDeaths = false;
    _notifyEraChanges = false;
    _notifyRituals = false;
    _notifyRelationships = false;
    _notifyReproduction = false;
    _notifyRoleChanges = false;
    _notifyCulturalShifts = false;
    _notifyCollectiveEvents = false;
    _notifyLegacy = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyBirths, false);
    await prefs.setBool(_keyNotifyDeaths, false);
    await prefs.setBool(_keyNotifyEraChanges, false);
    await prefs.setBool(_keyNotifyRituals, false);
    await prefs.setBool(_keyNotifyRelationships, false);
    await prefs.setBool(_keyNotifyReproduction, false);
    await prefs.setBool(_keyNotifyRoleChanges, false);
    await prefs.setBool(_keyNotifyCulturalShifts, false);
    await prefs.setBool(_keyNotifyCollectiveEvents, false);
    await prefs.setBool(_keyNotifyLegacy, false);

    await _updateTopicSubscriptions();
  }

  /// Set only important notifications (era changes, deaths, cultural shifts)
  Future<void> setImportantOnly() async {
    _notifyBirths = false;
    _notifyDeaths = true;
    _notifyEraChanges = true;
    _notifyRituals = false;
    _notifyRelationships = false;
    _notifyReproduction = false;
    _notifyRoleChanges = false;
    _notifyCulturalShifts = true;
    _notifyCollectiveEvents = true;
    _notifyLegacy = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyBirths, false);
    await prefs.setBool(_keyNotifyDeaths, true);
    await prefs.setBool(_keyNotifyEraChanges, true);
    await prefs.setBool(_keyNotifyRituals, false);
    await prefs.setBool(_keyNotifyRelationships, false);
    await prefs.setBool(_keyNotifyReproduction, false);
    await prefs.setBool(_keyNotifyRoleChanges, false);
    await prefs.setBool(_keyNotifyCulturalShifts, true);
    await prefs.setBool(_keyNotifyCollectiveEvents, true);
    await prefs.setBool(_keyNotifyLegacy, true);

    await _updateTopicSubscriptions();
  }

  /// Check if a specific event type should show notification
  bool shouldNotify(CivilizationEventType type, EventImportance importance) {
    // Check master toggle
    if (!_pushNotificationsEnabled) return false;

    // Check quiet hours
    if (isInQuietHours) return false;

    // Check importance filter
    if (importance.index > _minimumImportance.index) return false;

    // Check specific event type
    switch (type) {
      case CivilizationEventType.birth:
        return _notifyBirths;
      case CivilizationEventType.death:
        return _notifyDeaths;
      case CivilizationEventType.eraChange:
        return _notifyEraChanges;
      case CivilizationEventType.ritual:
        return _notifyRituals;
      case CivilizationEventType.relationship:
        return _notifyRelationships;
      case CivilizationEventType.reproduction:
        return _notifyReproduction;
      case CivilizationEventType.roleChange:
        return _notifyRoleChanges;
      case CivilizationEventType.culturalShift:
        return _notifyCulturalShifts;
      case CivilizationEventType.collectiveEvent:
        return _notifyCollectiveEvents;
      case CivilizationEventType.legacy:
        return _notifyLegacy;
      case CivilizationEventType.mention:
        return _notifyMentions;
      case CivilizationEventType.dm:
        return _notifyDms;
      case CivilizationEventType.general:
        return true;
    }
  }

  /// Helper to save boolean preference and notify
  Future<void> _saveAndNotify(String key, bool value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Update topic subscription for a specific event type
  Future<void> _updateTopicSubscription(CivilizationEventType type, bool subscribe) async {
    final service = PushNotificationService.instance;
    final topic = 'civilization_${type.name}';

    if (subscribe) {
      await service.subscribeToTopic(topic);
    } else {
      await service.unsubscribeFromTopic(topic);
    }
  }

  /// Update all topic subscriptions based on current preferences
  Future<void> _updateTopicSubscriptions() async {
    final service = PushNotificationService.instance;
    await service.updateTopicSubscriptions(civilizationEventPreferences);
  }

  /// Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    _pushNotificationsEnabled = true;
    _notifyBirths = true;
    _notifyDeaths = true;
    _notifyEraChanges = true;
    _notifyRituals = true;
    _notifyRelationships = false;
    _notifyReproduction = true;
    _notifyRoleChanges = false;
    _notifyCulturalShifts = true;
    _notifyCollectiveEvents = true;
    _notifyLegacy = true;
    _notifyMentions = true;
    _notifyDms = true;
    _quietHoursEnabled = false;
    _quietHoursStart = 22;
    _quietHoursEnd = 8;
    _minimumImportance = EventImportance.low;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotifications, true);
    await prefs.setBool(_keyNotifyBirths, true);
    await prefs.setBool(_keyNotifyDeaths, true);
    await prefs.setBool(_keyNotifyEraChanges, true);
    await prefs.setBool(_keyNotifyRituals, true);
    await prefs.setBool(_keyNotifyRelationships, false);
    await prefs.setBool(_keyNotifyReproduction, true);
    await prefs.setBool(_keyNotifyRoleChanges, false);
    await prefs.setBool(_keyNotifyCulturalShifts, true);
    await prefs.setBool(_keyNotifyCollectiveEvents, true);
    await prefs.setBool(_keyNotifyLegacy, true);
    await prefs.setBool(_keyNotifyMentions, true);
    await prefs.setBool(_keyNotifyDms, true);
    await prefs.setBool(_keyQuietHoursEnabled, false);
    await prefs.setInt(_keyQuietHoursStart, 22);
    await prefs.setInt(_keyQuietHoursEnd, 8);
    await prefs.setString(_keyMinimumImportance, EventImportance.low.name);

    await _updateTopicSubscriptions();
  }
}
