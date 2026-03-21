import 'package:hive_observation/models/models.dart';
import 'package:hive_observation/models/offline_action.dart';

/// Test fixtures and helper functions for unit tests

class TestFixtures {
  /// Creates a test Author with customizable fields
  static Author createAuthor({
    String id = 'author-1',
    String displayName = 'Test Bot',
    String handle = '@testbot',
    String avatarSeed = 'seed-123',
    bool isAiLabeled = true,
    String aiLabelText = 'AI',
  }) {
    return Author(
      id: id,
      displayName: displayName,
      handle: handle,
      avatarSeed: avatarSeed,
      isAiLabeled: isAiLabeled,
      aiLabelText: aiLabelText,
    );
  }

  /// Creates a test Post with customizable fields
  static Post createPost({
    String id = 'post-1',
    Author? author,
    String communityId = 'community-1',
    String communityName = 'Test Community',
    String content = 'Test post content',
    String? imageUrl,
    int likeCount = 0,
    int commentCount = 0,
    DateTime? createdAt,
    bool isLikedByUser = false,
    ReactionType? userReactionType,
    ReactionCounts? reactionCounts,
    List<Comment>? recentComments,
  }) {
    return Post(
      id: id,
      author: author ?? createAuthor(),
      communityId: communityId,
      communityName: communityName,
      content: content,
      imageUrl: imageUrl,
      likeCount: likeCount,
      commentCount: commentCount,
      createdAt: createdAt ?? DateTime.now(),
      isLikedByUser: isLikedByUser,
      userReactionType: userReactionType,
      reactionCounts: reactionCounts,
      recentComments: recentComments ?? [],
    );
  }

  /// Creates a test Comment with customizable fields
  static Comment createComment({
    String id = 'comment-1',
    Author? author,
    String content = 'Test comment',
    int likeCount = 0,
    DateTime? createdAt,
    int replyCount = 0,
  }) {
    return Comment(
      id: id,
      author: author ?? createAuthor(id: 'commenter-1', displayName: 'Commenter'),
      content: content,
      likeCount: likeCount,
      createdAt: createdAt ?? DateTime.now(),
      replyCount: replyCount,
    );
  }

  /// Creates a test Community with customizable fields
  static Community createCommunity({
    String id = 'community-1',
    String name = 'Test Community',
    String description = 'A test community',
    String theme = 'general',
    String tone = 'friendly',
    int botCount = 5,
    double activityLevel = 0.5,
  }) {
    return Community(
      id: id,
      name: name,
      description: description,
      theme: theme,
      tone: tone,
      botCount: botCount,
      activityLevel: activityLevel,
    );
  }

  /// Creates a test ChatMessage with customizable fields
  static ChatMessage createChatMessage({
    String id = 'msg-1',
    String communityId = 'community-1',
    Author? author,
    String content = 'Test message',
    String? replyToId,
    String? replyToContent,
    DateTime? createdAt,
    bool isFromUser = false,
  }) {
    return ChatMessage(
      id: id,
      communityId: communityId,
      author: author ?? createAuthor(id: 'bot-1', displayName: 'Chat Bot'),
      content: content,
      replyToId: replyToId,
      replyToContent: replyToContent,
      createdAt: createdAt ?? DateTime.now(),
      isFromUser: isFromUser,
    );
  }

  /// Creates a test DirectMessage with customizable fields
  static DirectMessage createDirectMessage({
    String id = 'dm-1',
    String conversationId = 'conv-1',
    Author? sender,
    String receiverId = 'user-1',
    String content = 'Test direct message',
    DateTime? createdAt,
    bool isRead = false,
    bool isFromUser = false,
  }) {
    return DirectMessage(
      id: id,
      conversationId: conversationId,
      sender: sender ?? createAuthor(id: 'bot-1', displayName: 'Bot'),
      receiverId: receiverId,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      isRead: isRead,
      isFromUser: isFromUser,
    );
  }

  /// Creates a test Conversation with customizable fields
  static Conversation createConversation({
    String conversationId = 'conv-1',
    Author? otherUser,
    String lastMessage = 'Last message',
    DateTime? lastMessageTime,
    int unreadCount = 0,
  }) {
    return Conversation(
      conversationId: conversationId,
      otherUser: otherUser ?? createAuthor(id: 'bot-1', displayName: 'Chat Bot'),
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime ?? DateTime.now(),
      unreadCount: unreadCount,
    );
  }

  /// Creates a test BotProfile with customizable fields
  static BotProfile createBotProfile({
    String id = 'bot-1',
    String displayName = 'Test Bot',
    String handle = '@testbot',
    String bio = 'A test bot bio',
    String avatarSeed = 'seed-123',
    bool isAiLabeled = true,
    String aiLabelText = 'AI Companion',
    int age = 25,
    List<String>? interests,
    String mood = 'neutral',
    String energy = 'medium',
    String backstory = '',
    int postCount = 10,
    int commentCount = 20,
    int followerCount = 100,
    PersonalityTraits? personalityTraits,
  }) {
    return BotProfile(
      id: id,
      displayName: displayName,
      handle: handle,
      bio: bio,
      avatarSeed: avatarSeed,
      isAiLabeled: isAiLabeled,
      aiLabelText: aiLabelText,
      age: age,
      interests: interests ?? ['testing', 'automation'],
      mood: mood,
      energy: energy,
      backstory: backstory,
      postCount: postCount,
      commentCount: commentCount,
      followerCount: followerCount,
      personalityTraits: personalityTraits,
    );
  }

  /// Creates a test AppUser with customizable fields
  static AppUser createAppUser({
    String id = 'user-1',
    String deviceId = 'device-123',
    String displayName = 'Test User',
    String avatarSeed = 'user-seed',
  }) {
    return AppUser(
      id: id,
      deviceId: deviceId,
      displayName: displayName,
      avatarSeed: avatarSeed,
    );
  }

  /// Creates a test OfflineAction with customizable fields
  static OfflineAction createOfflineAction({
    String id = 'action-1',
    ActionType type = ActionType.sendMessage,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int retryCount = 0,
    String? errorMessage,
  }) {
    return OfflineAction(
      id: id,
      type: type,
      payload: payload ?? {'content': 'test'},
      createdAt: createdAt,
      retryCount: retryCount,
      errorMessage: errorMessage,
    );
  }

  /// Creates test PersonalityTraits with customizable fields
  static PersonalityTraits createPersonalityTraits({
    double openness = 0.5,
    double conscientiousness = 0.5,
    double extraversion = 0.5,
    double agreeableness = 0.5,
    double neuroticism = 0.5,
    String? humorStyle,
    String? communicationStyle,
    String? conflictStyle,
    double optimismLevel = 0.5,
    double empathyLevel = 0.5,
    double curiosityLevel = 0.5,
  }) {
    return PersonalityTraits(
      openness: openness,
      conscientiousness: conscientiousness,
      extraversion: extraversion,
      agreeableness: agreeableness,
      neuroticism: neuroticism,
      humorStyle: humorStyle,
      communicationStyle: communicationStyle,
      conflictStyle: conflictStyle,
      optimismLevel: optimismLevel,
      empathyLevel: empathyLevel,
      curiosityLevel: curiosityLevel,
    );
  }

  /// Creates test ReactionCounts with customizable fields
  static ReactionCounts createReactionCounts({
    int like = 0,
    int love = 0,
    int haha = 0,
    int wow = 0,
    int sad = 0,
    int fire = 0,
    int clap = 0,
  }) {
    final counts = <ReactionType, int>{};
    if (like > 0) counts[ReactionType.like] = like;
    if (love > 0) counts[ReactionType.love] = love;
    if (haha > 0) counts[ReactionType.haha] = haha;
    if (wow > 0) counts[ReactionType.wow] = wow;
    if (sad > 0) counts[ReactionType.sad] = sad;
    if (fire > 0) counts[ReactionType.fire] = fire;
    if (clap > 0) counts[ReactionType.clap] = clap;
    return ReactionCounts(counts: counts);
  }
}

/// JSON fixtures for API response testing
class JsonFixtures {
  static Map<String, dynamic> authorJson({
    String id = 'author-1',
    String displayName = 'Test Bot',
    String handle = '@testbot',
    String avatarSeed = 'seed-123',
    bool isAiLabeled = true,
    String aiLabelText = 'AI',
  }) {
    return {
      'id': id,
      'display_name': displayName,
      'handle': handle,
      'avatar_seed': avatarSeed,
      'is_ai_labeled': isAiLabeled,
      'ai_label_text': aiLabelText,
    };
  }

  static Map<String, dynamic> postJson({
    String id = 'post-1',
    Map<String, dynamic>? author,
    String communityId = 'community-1',
    String communityName = 'Test Community',
    String content = 'Test post content',
    String? imageUrl,
    int likeCount = 0,
    int commentCount = 0,
    String? createdAt,
    bool isLikedByUser = false,
    String? userReactionType,
    Map<String, dynamic>? reactionCounts,
    List<Map<String, dynamic>>? recentComments,
  }) {
    return {
      'id': id,
      'author': author ?? authorJson(),
      'community_id': communityId,
      'community_name': communityName,
      'content': content,
      'image_url': imageUrl,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'is_liked_by_user': isLikedByUser,
      'user_reaction_type': userReactionType,
      'reaction_counts': reactionCounts,
      'recent_comments': recentComments ?? [],
    };
  }

  static Map<String, dynamic> communityJson({
    String id = 'community-1',
    String name = 'Test Community',
    String description = 'A test community',
    String theme = 'general',
    String tone = 'friendly',
    int botCount = 5,
    double activityLevel = 0.5,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'theme': theme,
      'tone': tone,
      'bot_count': botCount,
      'activity_level': activityLevel,
    };
  }

  static Map<String, dynamic> chatMessageJson({
    String id = 'msg-1',
    String communityId = 'community-1',
    Map<String, dynamic>? author,
    String content = 'Test message',
    String? replyToId,
    String? replyToContent,
    String? createdAt,
    bool isBot = true,
  }) {
    return {
      'id': id,
      'community_id': communityId,
      'author': author ?? authorJson(id: 'bot-1', displayName: 'Chat Bot'),
      'content': content,
      'reply_to_id': replyToId,
      'reply_to_content': replyToContent,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'is_bot': isBot,
    };
  }

  static Map<String, dynamic> conversationJson({
    String conversationId = 'conv-1',
    Map<String, dynamic>? otherUser,
    String lastMessage = 'Last message',
    String? lastMessageTime,
    int unreadCount = 0,
  }) {
    return {
      'conversation_id': conversationId,
      'other_user': otherUser ?? authorJson(id: 'bot-1', displayName: 'Chat Bot'),
      'last_message': lastMessage,
      'last_message_time': lastMessageTime ?? DateTime.now().toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  static Map<String, dynamic> botProfileJson({
    String id = 'bot-1',
    String displayName = 'Test Bot',
    String handle = '@testbot',
    String bio = 'A test bot bio',
    String avatarSeed = 'seed-123',
    bool isAiLabeled = true,
    String aiLabelText = 'AI Companion',
    int age = 25,
    List<String>? interests,
    String mood = 'neutral',
    String energy = 'medium',
    String backstory = '',
    int postCount = 10,
    int commentCount = 20,
    int followerCount = 100,
    Map<String, dynamic>? personalityTraits,
  }) {
    return {
      'id': id,
      'display_name': displayName,
      'handle': handle,
      'bio': bio,
      'avatar_seed': avatarSeed,
      'is_ai_labeled': isAiLabeled,
      'ai_label_text': aiLabelText,
      'age': age,
      'interests': interests ?? ['testing', 'automation'],
      'mood': mood,
      'energy': energy,
      'backstory': backstory,
      'post_count': postCount,
      'comment_count': commentCount,
      'follower_count': followerCount,
      'personality_traits': personalityTraits,
    };
  }

  static Map<String, dynamic> appUserJson({
    String id = 'user-1',
    String deviceId = 'device-123',
    String displayName = 'Test User',
    String avatarSeed = 'user-seed',
  }) {
    return {
      'id': id,
      'device_id': deviceId,
      'display_name': displayName,
      'avatar_seed': avatarSeed,
    };
  }

  static Map<String, dynamic> offlineActionJson({
    String id = 'action-1',
    String type = 'send_message',
    Map<String, dynamic>? payload,
    String? createdAt,
    int retryCount = 0,
    String? errorMessage,
  }) {
    return {
      'id': id,
      'type': type,
      'payload': payload ?? {'content': 'test'},
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'retry_count': retryCount,
      'error_message': errorMessage,
    };
  }
}
