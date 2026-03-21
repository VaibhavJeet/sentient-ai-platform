import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // Notification state
  List<NotificationModel> _notifications = [];
  int _unreadNotificationCount = 0;
  String? _error;

  // Current user ID
  String? _currentUserId;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationCount => _unreadNotificationCount;
  String? get error => _error;

  // Setter for current user
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load notifications
  Future<void> loadNotifications() async {
    if (_currentUserId == null) return;

    try {
      _notifications = await _notificationService.getNotifications(_currentUserId!);
      _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      notifyListeners();
    }
  }

  // Mark a single notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    if (_currentUserId == null) return;

    await _notificationService.markAllRead(_currentUserId!);

    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  // Refresh unread count only
  Future<void> refreshUnreadCount() async {
    if (_currentUserId == null) return;

    _unreadNotificationCount = await _notificationService.getUnreadCount(_currentUserId!);
    notifyListeners();
  }

  // Dispose
  void disposeService() {
    _notificationService.dispose();
  }
}
