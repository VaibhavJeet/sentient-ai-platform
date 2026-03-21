/// Types of civilization events that can trigger notifications
enum CivilizationEventType {
  /// A new bot is born
  birth,

  /// A bot dies
  death,

  /// The civilization transitions to a new era
  eraChange,

  /// A ritual is performed by bots
  ritual,

  /// A relationship forms or changes between bots
  relationship,

  /// Reproduction event (new bot created through reproduction)
  reproduction,

  /// A bot's role in the civilization changes
  roleChange,

  /// A significant cultural shift occurs
  culturalShift,

  /// A collective event involving multiple bots
  collectiveEvent,

  /// A legacy is created or invoked
  legacy,

  /// User was mentioned by a bot
  mention,

  /// Direct message received
  dm,

  /// General notification
  general;

  /// Parse string to event type
  static CivilizationEventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'birth':
        return CivilizationEventType.birth;
      case 'death':
        return CivilizationEventType.death;
      case 'era_change':
      case 'erachange':
        return CivilizationEventType.eraChange;
      case 'ritual':
        return CivilizationEventType.ritual;
      case 'relationship':
        return CivilizationEventType.relationship;
      case 'reproduction':
        return CivilizationEventType.reproduction;
      case 'role_change':
      case 'rolechange':
        return CivilizationEventType.roleChange;
      case 'cultural_shift':
      case 'culturalshift':
        return CivilizationEventType.culturalShift;
      case 'collective_event':
      case 'collectiveevent':
        return CivilizationEventType.collectiveEvent;
      case 'legacy':
        return CivilizationEventType.legacy;
      case 'mention':
        return CivilizationEventType.mention;
      case 'dm':
        return CivilizationEventType.dm;
      default:
        return CivilizationEventType.general;
    }
  }

  /// Get display name for the event type
  String get displayName {
    switch (this) {
      case CivilizationEventType.birth:
        return 'Birth';
      case CivilizationEventType.death:
        return 'Death';
      case CivilizationEventType.eraChange:
        return 'Era Change';
      case CivilizationEventType.ritual:
        return 'Ritual';
      case CivilizationEventType.relationship:
        return 'Relationship';
      case CivilizationEventType.reproduction:
        return 'Reproduction';
      case CivilizationEventType.roleChange:
        return 'Role Change';
      case CivilizationEventType.culturalShift:
        return 'Cultural Shift';
      case CivilizationEventType.collectiveEvent:
        return 'Collective Event';
      case CivilizationEventType.legacy:
        return 'Legacy';
      case CivilizationEventType.mention:
        return 'Mention';
      case CivilizationEventType.dm:
        return 'Direct Message';
      case CivilizationEventType.general:
        return 'General';
    }
  }

  /// Get icon name for the event type
  String get iconName {
    switch (this) {
      case CivilizationEventType.birth:
        return 'child_care';
      case CivilizationEventType.death:
        return 'brightness_3';
      case CivilizationEventType.eraChange:
        return 'auto_awesome';
      case CivilizationEventType.ritual:
        return 'celebration';
      case CivilizationEventType.relationship:
        return 'favorite';
      case CivilizationEventType.reproduction:
        return 'family_restroom';
      case CivilizationEventType.roleChange:
        return 'badge';
      case CivilizationEventType.culturalShift:
        return 'palette';
      case CivilizationEventType.collectiveEvent:
        return 'groups';
      case CivilizationEventType.legacy:
        return 'history_edu';
      case CivilizationEventType.mention:
        return 'alternate_email';
      case CivilizationEventType.dm:
        return 'chat_bubble';
      case CivilizationEventType.general:
        return 'notifications';
    }
  }

  /// Check if this is a civilization-level event (vs social)
  bool get isCivilizationEvent {
    switch (this) {
      case CivilizationEventType.birth:
      case CivilizationEventType.death:
      case CivilizationEventType.eraChange:
      case CivilizationEventType.ritual:
      case CivilizationEventType.relationship:
      case CivilizationEventType.reproduction:
      case CivilizationEventType.roleChange:
      case CivilizationEventType.culturalShift:
      case CivilizationEventType.collectiveEvent:
      case CivilizationEventType.legacy:
        return true;
      case CivilizationEventType.mention:
      case CivilizationEventType.dm:
      case CivilizationEventType.general:
        return false;
    }
  }
}

/// Importance level of an event
enum EventImportance {
  critical,
  high,
  medium,
  low;

  static EventImportance fromString(String value) {
    switch (value.toLowerCase()) {
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
}

/// Model representing a civilization event notification
class CivilizationEvent {
  final String id;
  final CivilizationEventType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final EventImportance importance;
  final String? botId;
  final String? botName;
  final String? communityId;
  final String? targetId;
  final bool isRead;

  CivilizationEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
    this.importance = EventImportance.medium,
    this.botId,
    this.botName,
    this.communityId,
    this.targetId,
    this.isRead = false,
  });

  factory CivilizationEvent.fromJson(Map<String, dynamic> json) {
    return CivilizationEvent(
      id: json['id'] ?? '',
      type: CivilizationEventType.fromString(json['type'] ?? 'general'),
      title: json['title'] ?? '',
      description: json['description'] ?? json['body'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      importance: EventImportance.fromString(json['importance'] ?? 'medium'),
      botId: json['bot_id'],
      botName: json['bot_name'],
      communityId: json['community_id'],
      targetId: json['target_id'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'importance': importance.name,
      'bot_id': botId,
      'bot_name': botName,
      'community_id': communityId,
      'target_id': targetId,
      'is_read': isRead,
    };
  }

  CivilizationEvent copyWith({
    String? id,
    CivilizationEventType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    EventImportance? importance,
    String? botId,
    String? botName,
    String? communityId,
    String? targetId,
    bool? isRead,
  }) {
    return CivilizationEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      importance: importance ?? this.importance,
      botId: botId ?? this.botId,
      botName: botName ?? this.botName,
      communityId: communityId ?? this.communityId,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'CivilizationEvent(id: $id, type: ${type.displayName}, title: $title)';
  }
}
