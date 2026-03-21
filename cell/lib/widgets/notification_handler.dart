import 'dart:async';

import 'package:flutter/material.dart';

import '../models/civilization_event.dart';
import '../services/push_notification_service.dart';
import '../theme/app_theme.dart';

/// Widget that listens for push notifications and handles them
///
/// Wrap this around your app's main content to receive notifications
/// and optionally show in-app banners for foreground messages.
class NotificationHandler extends StatefulWidget {
  final Widget child;
  final bool showInAppNotifications;
  final void Function(CivilizationEvent)? onNotificationReceived;
  final void Function(CivilizationEvent)? onNotificationTapped;

  const NotificationHandler({
    super.key,
    required this.child,
    this.showInAppNotifications = true,
    this.onNotificationReceived,
    this.onNotificationTapped,
  });

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  StreamSubscription<CivilizationEvent>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    final pushService = PushNotificationService.instance;

    if (!pushService.isInitialized) {
      // Service not initialized yet, will be handled when it initializes
      return;
    }

    _notificationSubscription = pushService.onNotificationReceived.listen((event) {
      widget.onNotificationReceived?.call(event);

      if (widget.showInAppNotifications && mounted) {
        _showInAppNotification(event);
      }
    });
  }

  void _showInAppNotification(CivilizationEvent event) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        event: event,
        onTap: () {
          entry.remove();
          widget.onNotificationTapped?.call(event);
        },
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// In-app notification banner widget
class _InAppNotificationBanner extends StatefulWidget {
  final CivilizationEvent event;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.event,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getEventColor() {
    switch (widget.event.type) {
      case CivilizationEventType.birth:
        return Colors.green;
      case CivilizationEventType.death:
        return Colors.grey;
      case CivilizationEventType.eraChange:
        return Colors.purple;
      case CivilizationEventType.ritual:
        return Colors.orange;
      case CivilizationEventType.reproduction:
        return Colors.pink;
      case CivilizationEventType.culturalShift:
        return Colors.blue;
      case CivilizationEventType.collectiveEvent:
        return Colors.teal;
      case CivilizationEventType.legacy:
        return Colors.amber;
      case CivilizationEventType.relationship:
        return Colors.red;
      case CivilizationEventType.roleChange:
        return Colors.indigo;
      case CivilizationEventType.mention:
        return AppTheme.primaryColor;
      case CivilizationEventType.dm:
        return AppTheme.accentColor;
      case CivilizationEventType.general:
        return AppTheme.primaryColor;
    }
  }

  IconData _getEventIcon() {
    switch (widget.event.type) {
      case CivilizationEventType.birth:
        return Icons.child_care;
      case CivilizationEventType.death:
        return Icons.brightness_3;
      case CivilizationEventType.eraChange:
        return Icons.auto_awesome;
      case CivilizationEventType.ritual:
        return Icons.celebration;
      case CivilizationEventType.reproduction:
        return Icons.family_restroom;
      case CivilizationEventType.culturalShift:
        return Icons.palette;
      case CivilizationEventType.collectiveEvent:
        return Icons.groups;
      case CivilizationEventType.legacy:
        return Icons.history_edu;
      case CivilizationEventType.relationship:
        return Icons.favorite;
      case CivilizationEventType.roleChange:
        return Icons.badge;
      case CivilizationEventType.mention:
        return Icons.alternate_email;
      case CivilizationEventType.dm:
        return Icons.chat_bubble;
      case CivilizationEventType.general:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor();
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity!.abs() > 100) {
                  widget.onDismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cyberDark,
                      AppTheme.cyberDeeper,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getEventIcon(),
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.event.type.displayName,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.event.description,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Dismiss button
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
