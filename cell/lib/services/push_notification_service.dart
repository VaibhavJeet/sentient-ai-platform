import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env_config.dart';
import '../models/civilization_event.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed for background handling
  await Firebase.initializeApp();
  debugPrint('PushNotificationService: Handling background message: ${message.messageId}');

  // Handle the message data
  await PushNotificationService._handleBackgroundMessage(message);
}

/// Service for handling push notifications via Firebase Cloud Messaging
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  static PushNotificationService get instance => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Stream controllers for notification events
  final StreamController<CivilizationEvent> _notificationStreamController =
      StreamController<CivilizationEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _tokenRefreshController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Notification channel for Android
  static const AndroidNotificationChannel _civilizationChannel = AndroidNotificationChannel(
    'civilization_events',
    'Civilization Events',
    description: 'Notifications for significant events in the digital civilization',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  static const AndroidNotificationChannel _socialChannel = AndroidNotificationChannel(
    'social_notifications',
    'Social Notifications',
    description: 'Notifications for social interactions like mentions and DMs',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  // FCM token
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Streams
  Stream<CivilizationEvent> get onNotificationReceived => _notificationStreamController.stream;
  Stream<Map<String, dynamic>> get onTokenRefresh => _tokenRefreshController.stream;

  // Initialization state
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the push notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Create notification channels for Android
      if (!kIsWeb && Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Request permission
      await requestPermission();

      // Get initial FCM token
      await _getToken();

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Set up message handlers
      _setupMessageHandlers();

      _isInitialized = true;
      debugPrint('PushNotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('PushNotificationService: Initialization error: $e');
      rethrow;
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_civilizationChannel);
      await androidPlugin.createNotificationChannel(_socialChannel);
    }
  }

  /// Request notification permission
  Future<NotificationPermissionStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('PushNotificationService: Permission status: ${settings.authorizationStatus}');

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.provisional;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
    }
  }

  /// Get current permission status
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.provisional;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
    }
  }

  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('PushNotificationService: FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await _saveToken(_fcmToken!);
        await _registerTokenWithServer(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('PushNotificationService: Error getting token: $e');
      return null;
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) {
    debugPrint('PushNotificationService: Token refreshed: $token');
    _fcmToken = token;
    _saveToken(token);
    _registerTokenWithServer(token);
    _tokenRefreshController.add({'token': token});
  }

  /// Save token locally
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Get saved token
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Register token with backend server
  Future<void> _registerTokenWithServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        debugPrint('PushNotificationService: No device ID, skipping token registration');
        return;
      }

      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/notifications/register-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'fcm_token': token,
          'platform': _getPlatform(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('PushNotificationService: Token registered with server');
      } else {
        debugPrint('PushNotificationService: Failed to register token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('PushNotificationService: Error registering token: $e');
    }
  }

  /// Unregister token from server (e.g., on logout)
  Future<void> unregisterToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');

      if (deviceId == null || _fcmToken == null) return;

      await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}/notifications/unregister-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'fcm_token': _fcmToken,
        }),
      );

      await _messaging.deleteToken();
      _fcmToken = null;

      debugPrint('PushNotificationService: Token unregistered');
    } catch (e) {
      debugPrint('PushNotificationService: Error unregistering token: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when user taps notification and app opens from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    _checkInitialMessage();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('PushNotificationService: Foreground message received: ${message.messageId}');

    final event = _parseMessageToCivilizationEvent(message);
    if (event != null) {
      _notificationStreamController.add(event);

      // Show local notification
      await _showLocalNotification(message, event);
    }
  }

  /// Handle when app is opened from background via notification tap
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('PushNotificationService: App opened from notification: ${message.messageId}');

    final event = _parseMessageToCivilizationEvent(message);
    if (event != null) {
      _notificationStreamController.add(event);
    }
  }

  /// Check if app was opened from terminated state via notification
  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message != null) {
      debugPrint('PushNotificationService: App opened from terminated state via notification');

      final event = _parseMessageToCivilizationEvent(message);
      if (event != null) {
        // Delay to ensure app is fully initialized
        await Future.delayed(const Duration(milliseconds: 500));
        _notificationStreamController.add(event);
      }
    }
  }

  /// Handle background message (static for top-level function)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('PushNotificationService: Background message: ${message.data}');
    // Background messages are handled by the system notification
    // The data will be processed when the user taps the notification
  }

  /// Parse FCM message to CivilizationEvent
  CivilizationEvent? _parseMessageToCivilizationEvent(RemoteMessage message) {
    try {
      final data = message.data;

      return CivilizationEvent(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: CivilizationEventType.fromString(data['event_type'] ?? 'general'),
        title: message.notification?.title ?? data['title'] ?? 'Civilization Event',
        description: message.notification?.body ?? data['body'] ?? '',
        timestamp: DateTime.now(),
        metadata: data,
        importance: _parseImportance(data['importance']),
      );
    } catch (e) {
      debugPrint('PushNotificationService: Error parsing message: $e');
      return null;
    }
  }

  /// Parse importance level
  EventImportance _parseImportance(String? importance) {
    switch (importance?.toLowerCase()) {
      case 'critical':
        return EventImportance.critical;
      case 'high':
        return EventImportance.high;
      case 'medium':
        return EventImportance.medium;
      case 'low':
        return EventImportance.low;
      default:
        return EventImportance.medium;
    }
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message, CivilizationEvent event) async {
    // Check if notifications are enabled for this event type
    final prefs = await SharedPreferences.getInstance();
    if (!_shouldShowNotification(event.type, prefs)) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      event.type.isCivilizationEvent ? _civilizationChannel.id : _socialChannel.id,
      event.type.isCivilizationEvent ? _civilizationChannel.name : _socialChannel.name,
      channelDescription: event.type.isCivilizationEvent
          ? _civilizationChannel.description
          : _socialChannel.description,
      importance: _mapImportanceToAndroid(event.importance),
      priority: _mapPriorityToAndroid(event.importance),
      icon: '@mipmap/ic_launcher',
      color: _getNotificationColor(event.type),
      styleInformation: BigTextStyleInformation(
        event.description,
        contentTitle: event.title,
        summaryText: event.type.displayName,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      event.id.hashCode,
      event.title,
      event.description,
      details,
      payload: jsonEncode(event.toJson()),
    );
  }

  /// Check if notification should be shown based on preferences
  bool _shouldShowNotification(CivilizationEventType type, SharedPreferences prefs) {
    // Master toggle
    if (!(prefs.getBool('push_notifications') ?? true)) {
      return false;
    }

    // Event-specific toggles
    switch (type) {
      case CivilizationEventType.birth:
        return prefs.getBool('notify_births') ?? true;
      case CivilizationEventType.death:
        return prefs.getBool('notify_deaths') ?? true;
      case CivilizationEventType.eraChange:
        return prefs.getBool('notify_era_changes') ?? true;
      case CivilizationEventType.ritual:
        return prefs.getBool('notify_rituals') ?? true;
      case CivilizationEventType.relationship:
        return prefs.getBool('notify_relationships') ?? false;
      case CivilizationEventType.reproduction:
        return prefs.getBool('notify_reproduction') ?? true;
      case CivilizationEventType.roleChange:
        return prefs.getBool('notify_role_changes') ?? false;
      case CivilizationEventType.culturalShift:
        return prefs.getBool('notify_cultural_shifts') ?? true;
      case CivilizationEventType.collectiveEvent:
        return prefs.getBool('notify_collective_events') ?? true;
      case CivilizationEventType.legacy:
        return prefs.getBool('notify_legacy') ?? true;
      case CivilizationEventType.mention:
        return prefs.getBool('mention_notifications') ?? true;
      case CivilizationEventType.dm:
        return prefs.getBool('dm_notifications') ?? true;
      case CivilizationEventType.general:
        return true;
    }
  }

  /// Map event importance to Android importance
  Importance _mapImportanceToAndroid(EventImportance importance) {
    switch (importance) {
      case EventImportance.critical:
        return Importance.max;
      case EventImportance.high:
        return Importance.high;
      case EventImportance.medium:
        return Importance.defaultImportance;
      case EventImportance.low:
        return Importance.low;
    }
  }

  /// Map event importance to Android priority
  Priority _mapPriorityToAndroid(EventImportance importance) {
    switch (importance) {
      case EventImportance.critical:
        return Priority.max;
      case EventImportance.high:
        return Priority.high;
      case EventImportance.medium:
        return Priority.defaultPriority;
      case EventImportance.low:
        return Priority.low;
    }
  }

  /// Get notification color based on event type
  int _getNotificationColor(CivilizationEventType type) {
    switch (type) {
      case CivilizationEventType.birth:
        return 0xFF4CAF50; // Green
      case CivilizationEventType.death:
        return 0xFF9E9E9E; // Grey
      case CivilizationEventType.eraChange:
        return 0xFF9C27B0; // Purple
      case CivilizationEventType.ritual:
        return 0xFFFF9800; // Orange
      case CivilizationEventType.reproduction:
        return 0xFFE91E63; // Pink
      case CivilizationEventType.culturalShift:
        return 0xFF2196F3; // Blue
      default:
        return 0xFF8B5CF6; // Primary purple
    }
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('PushNotificationService: Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final event = CivilizationEvent.fromJson(data);
        _instance._notificationStreamController.add(event);
      } catch (e) {
        debugPrint('PushNotificationService: Error parsing notification payload: $e');
      }
    }
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('PushNotificationService: Background notification tapped');
    // This will be handled when the app opens
  }

  /// Get platform string
  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('PushNotificationService: Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('PushNotificationService: Unsubscribed from topic: $topic');
  }

  /// Subscribe to civilization event topics based on preferences
  Future<void> updateTopicSubscriptions(Map<CivilizationEventType, bool> preferences) async {
    for (final entry in preferences.entries) {
      final topic = 'civilization_${entry.key.name}';
      if (entry.value) {
        await subscribeToTopic(topic);
      } else {
        await unsubscribeFromTopic(topic);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
    _tokenRefreshController.close();
  }
}

/// Permission status enum
enum NotificationPermissionStatus {
  granted,
  denied,
  provisional,
  notDetermined,
}
