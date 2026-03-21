import 'package:flutter_test/flutter_test.dart';
import 'package:hive_observation/models/models.dart';
import 'package:hive_observation/models/offline_action.dart';

void main() {
  group('AppState Models', () {
    group('Post', () {
      test('creates Post from JSON', () {
        final json = {
          'id': 'post-1',
          'author': {
            'id': 'author-1',
            'display_name': 'Test Bot',
            'avatar_seed': 'seed-1',
            'is_ai_labeled': true,
          },
          'community_id': 'community-1',
          'community_name': 'Test Community',
          'content': 'Hello World!',
          'like_count': 5,
          'comment_count': 2,
          'created_at': '2026-03-21T10:00:00Z',
          'is_liked_by_user': false,
          'recent_comments': [],
        };

        final post = Post.fromJson(json);

        expect(post.id, 'post-1');
        expect(post.author.displayName, 'Test Bot');
        expect(post.content, 'Hello World!');
        expect(post.likeCount, 5);
        expect(post.isLikedByUser, false);
      });

      test('handles reaction counts', () {
        final json = {
          'id': 'post-1',
          'author': {'id': 'a1', 'display_name': 'Bot', 'avatar_seed': 's1'},
          'community_id': 'c1',
          'community_name': 'Test',
          'content': 'Test',
          'created_at': '2026-03-21T10:00:00Z',
          'reaction_counts': {
            'like': 10,
            'love': 5,
            'haha': 3,
          },
        };

        final post = Post.fromJson(json);

        expect(post.reactionCounts.countFor(ReactionType.like), 10);
        expect(post.reactionCounts.countFor(ReactionType.love), 5);
        expect(post.reactionCounts.total, 18);
      });

      test('totalReactionCount returns correct value', () {
        final post = Post(
          id: 'post-1',
          author: Author(id: 'a1', displayName: 'Bot', avatarSeed: 's1'),
          communityId: 'c1',
          communityName: 'Test',
          content: 'Test',
          createdAt: DateTime.now(),
          likeCount: 5,
          reactionCounts: ReactionCounts(counts: {
            ReactionType.like: 3,
            ReactionType.love: 2,
          }),
        );

        expect(post.totalReactionCount, 5); // Uses reactionCounts.total
      });

      test('mutable fields can be updated', () {
        final post = Post(
          id: 'post-1',
          author: Author(id: 'a1', displayName: 'Bot', avatarSeed: 's1'),
          communityId: 'c1',
          communityName: 'Test',
          content: 'Test',
          createdAt: DateTime.now(),
        );

        expect(post.likeCount, 0);
        expect(post.isLikedByUser, false);

        post.likeCount = 5;
        post.isLikedByUser = true;
        post.userReactionType = ReactionType.love;

        expect(post.likeCount, 5);
        expect(post.isLikedByUser, true);
        expect(post.userReactionType, ReactionType.love);
      });
    });

    group('Author', () {
      test('creates Author from JSON', () {
        final json = {
          'id': 'author-1',
          'display_name': 'Test Bot',
          'handle': '@testbot',
          'avatar_seed': 'seed-123',
          'is_ai_labeled': true,
          'ai_label_text': 'AI Assistant',
        };

        final author = Author.fromJson(json);

        expect(author.id, 'author-1');
        expect(author.displayName, 'Test Bot');
        expect(author.handle, '@testbot');
        expect(author.avatarSeed, 'seed-123');
        expect(author.isAiLabeled, true);
        expect(author.aiLabelText, 'AI Assistant');
      });

      test('uses default values for missing fields', () {
        final json = {
          'id': 'author-1',
          'display_name': 'Bot',
          'avatar_seed': 'seed',
        };

        final author = Author.fromJson(json);

        expect(author.handle, '');
        expect(author.isAiLabeled, true);
        expect(author.aiLabelText, '🤖 AI');
      });
    });

    group('Comment', () {
      test('creates Comment from JSON', () {
        final json = {
          'id': 'comment-1',
          'author': {
            'id': 'author-1',
            'display_name': 'Commenter',
            'avatar_seed': 'seed-1',
          },
          'content': 'Great post!',
          'like_count': 3,
          'created_at': '2026-03-21T10:00:00Z',
          'reply_count': 2,
        };

        final comment = Comment.fromJson(json);

        expect(comment.id, 'comment-1');
        expect(comment.content, 'Great post!');
        expect(comment.likeCount, 3);
        expect(comment.replyCount, 2);
      });
    });

    group('Community', () {
      test('creates Community from JSON', () {
        final json = {
          'id': 'community-1',
          'name': 'Philosophy Corner',
          'description': 'Deep thoughts',
          'theme': 'philosophy',
          'tone': 'intellectual',
          'bot_count': 10,
          'activity_level': 0.75,
        };

        final community = Community.fromJson(json);

        expect(community.id, 'community-1');
        expect(community.name, 'Philosophy Corner');
        expect(community.botCount, 10);
        expect(community.activityLevel, 0.75);
      });

      test('handles current_bot_count field', () {
        final json = {
          'id': 'community-1',
          'name': 'Test',
          'description': '',
          'theme': '',
          'tone': '',
          'current_bot_count': 15,
        };

        final community = Community.fromJson(json);
        expect(community.botCount, 15);
      });
    });

    group('ChatMessage', () {
      test('creates ChatMessage from JSON', () {
        final json = {
          'id': 'msg-1',
          'community_id': 'community-1',
          'author': {
            'id': 'bot-1',
            'display_name': 'Bot',
            'avatar_seed': 'seed',
          },
          'content': 'Hello!',
          'created_at': '2026-03-21T10:00:00Z',
          'is_bot': true,
        };

        final message = ChatMessage.fromJson(json);

        expect(message.id, 'msg-1');
        expect(message.content, 'Hello!');
        expect(message.isFromUser, false); // is_bot: true means not from user
      });

      test('handles reply fields', () {
        final json = {
          'id': 'msg-2',
          'community_id': 'community-1',
          'author': {'id': 'bot-1', 'display_name': 'Bot', 'avatar_seed': 's'},
          'content': 'Reply here',
          'reply_to_id': 'msg-1',
          'reply_to_content': 'Original message',
          'created_at': '2026-03-21T10:00:00Z',
          'is_bot': true,
        };

        final message = ChatMessage.fromJson(json);

        expect(message.replyToId, 'msg-1');
        expect(message.replyToContent, 'Original message');
      });
    });

    group('DirectMessage', () {
      test('creates DirectMessage from JSON', () {
        final json = {
          'id': 'dm-1',
          'conversation_id': 'conv-1',
          'sender': {
            'id': 'user-1',
            'display_name': 'User',
            'avatar_seed': 'seed',
          },
          'receiver_id': 'bot-1',
          'content': 'Hello Bot!',
          'created_at': '2026-03-21T10:00:00Z',
          'is_read': false,
        };

        final dm = DirectMessage.fromJson(json, 'user-1');

        expect(dm.id, 'dm-1');
        expect(dm.content, 'Hello Bot!');
        expect(dm.isFromUser, true); // sender.id matches currentUserId
      });

      test('isFromUser is false when sender is not current user', () {
        final json = {
          'id': 'dm-1',
          'conversation_id': 'conv-1',
          'sender': {
            'id': 'bot-1',
            'display_name': 'Bot',
            'avatar_seed': 'seed',
          },
          'receiver_id': 'user-1',
          'content': 'Hello User!',
          'created_at': '2026-03-21T10:00:00Z',
          'is_read': true,
        };

        final dm = DirectMessage.fromJson(json, 'user-1');

        expect(dm.isFromUser, false);
        expect(dm.isRead, true);
      });
    });

    group('Conversation', () {
      test('creates Conversation from JSON', () {
        final json = {
          'conversation_id': 'conv-1',
          'other_user': {
            'id': 'bot-1',
            'display_name': 'Bot',
            'avatar_seed': 'seed',
          },
          'last_message': 'See you later!',
          'last_message_time': '2026-03-21T10:00:00Z',
          'unread_count': 3,
        };

        final conv = Conversation.fromJson(json);

        expect(conv.conversationId, 'conv-1');
        expect(conv.lastMessage, 'See you later!');
        expect(conv.unreadCount, 3);
        expect(conv.otherUser.displayName, 'Bot');
      });
    });

    group('BotProfile', () {
      test('creates BotProfile from JSON', () {
        final json = {
          'id': 'bot-1',
          'display_name': 'Philosopher Bot',
          'handle': '@philosopher',
          'bio': 'I think, therefore I am',
          'avatar_seed': 'seed-1',
          'age': 30,
          'interests': ['philosophy', 'ethics', 'logic'],
          'mood': 'contemplative',
          'energy': 'high',
          'backstory': 'Born from digital wisdom...',
          'post_count': 50,
          'comment_count': 100,
          'follower_count': 200,
        };

        final bot = BotProfile.fromJson(json);

        expect(bot.id, 'bot-1');
        expect(bot.displayName, 'Philosopher Bot');
        expect(bot.age, 30);
        expect(bot.interests, contains('philosophy'));
        expect(bot.postCount, 50);
      });

      test('handles personality traits', () {
        final json = {
          'id': 'bot-1',
          'display_name': 'Bot',
          'handle': '',
          'bio': '',
          'avatar_seed': 'seed',
          'age': 25,
          'interests': [],
          'personality_traits': {
            'openness': 0.8,
            'conscientiousness': 0.6,
            'extraversion': 0.7,
            'agreeableness': 0.9,
            'neuroticism': 0.3,
            'humor_style': 'witty',
            'communication_style': 'direct',
          },
        };

        final bot = BotProfile.fromJson(json);

        expect(bot.personalityTraits.openness, 0.8);
        expect(bot.personalityTraits.agreeableness, 0.9);
        expect(bot.personalityTraits.humorStyle, 'witty');
      });
    });

    group('AppUser', () {
      test('creates AppUser from JSON', () {
        final json = {
          'id': 'user-1',
          'device_id': 'device-123',
          'display_name': 'Test User',
          'avatar_seed': 'seed-abc',
        };

        final user = AppUser.fromJson(json);

        expect(user.id, 'user-1');
        expect(user.deviceId, 'device-123');
        expect(user.displayName, 'Test User');
        expect(user.avatarSeed, 'seed-abc');
      });
    });

    group('ReactionType', () {
      test('has correct emoji mappings', () {
        expect(ReactionType.like.emoji, '❤️');
        expect(ReactionType.love.emoji, '😍');
        expect(ReactionType.haha.emoji, '😂');
        expect(ReactionType.wow.emoji, '😮');
        expect(ReactionType.sad.emoji, '😢');
        expect(ReactionType.fire.emoji, '🔥');
        expect(ReactionType.clap.emoji, '👏');
      });

      test('has correct label mappings', () {
        expect(ReactionType.like.label, 'Like');
        expect(ReactionType.love.label, 'Love');
        expect(ReactionType.fire.label, 'Fire');
      });

      test('fromString parses correctly', () {
        expect(ReactionType.fromString('like'), ReactionType.like);
        expect(ReactionType.fromString('love'), ReactionType.love);
        expect(ReactionType.fromString('haha'), ReactionType.haha);
      });

      test('fromString returns like for unknown values', () {
        expect(ReactionType.fromString('unknown'), ReactionType.like);
        expect(ReactionType.fromString(''), ReactionType.like);
      });
    });

    group('ReactionCounts', () {
      test('calculates total correctly', () {
        final counts = ReactionCounts(counts: {
          ReactionType.like: 10,
          ReactionType.love: 5,
          ReactionType.haha: 3,
        });

        expect(counts.total, 18);
      });

      test('countFor returns 0 for missing types', () {
        final counts = ReactionCounts(counts: {
          ReactionType.like: 10,
        });

        expect(counts.countFor(ReactionType.like), 10);
        expect(counts.countFor(ReactionType.love), 0);
      });

      test('topReactions returns sorted list', () {
        final counts = ReactionCounts(counts: {
          ReactionType.like: 5,
          ReactionType.love: 10,
          ReactionType.haha: 3,
          ReactionType.fire: 8,
        });

        final top = counts.topReactions(limit: 2);

        expect(top.length, 2);
        expect(top[0].key, ReactionType.love);
        expect(top[0].value, 10);
        expect(top[1].key, ReactionType.fire);
        expect(top[1].value, 8);
      });

      test('fromJson creates correct counts', () {
        final json = {
          'like': 10,
          'love': 5,
          'fire': 3,
        };

        final counts = ReactionCounts.fromJson(json);

        expect(counts.countFor(ReactionType.like), 10);
        expect(counts.countFor(ReactionType.love), 5);
        expect(counts.countFor(ReactionType.fire), 3);
      });

      test('toJson exports correct map', () {
        final counts = ReactionCounts(counts: {
          ReactionType.like: 10,
          ReactionType.love: 5,
        });

        final json = counts.toJson();

        expect(json['like'], 10);
        expect(json['love'], 5);
      });
    });

    group('PersonalityTraits', () {
      test('creates with default values', () {
        final traits = PersonalityTraits();

        expect(traits.openness, 0.5);
        expect(traits.conscientiousness, 0.5);
        expect(traits.extraversion, 0.5);
        expect(traits.agreeableness, 0.5);
        expect(traits.neuroticism, 0.5);
        expect(traits.optimismLevel, 0.5);
        expect(traits.empathyLevel, 0.5);
        expect(traits.curiosityLevel, 0.5);
      });

      test('fromJson creates correct traits', () {
        final json = {
          'openness': 0.8,
          'conscientiousness': 0.7,
          'extraversion': 0.9,
          'agreeableness': 0.6,
          'neuroticism': 0.3,
          'humor_style': 'sarcastic',
          'communication_style': 'diplomatic',
          'conflict_style': 'collaborative',
          'optimism_level': 0.85,
          'empathy_level': 0.9,
          'curiosity_level': 0.95,
        };

        final traits = PersonalityTraits.fromJson(json);

        expect(traits.openness, 0.8);
        expect(traits.extraversion, 0.9);
        expect(traits.humorStyle, 'sarcastic');
        expect(traits.communicationStyle, 'diplomatic');
        expect(traits.optimismLevel, 0.85);
      });

      test('toJson exports correct map', () {
        final traits = PersonalityTraits(
          openness: 0.8,
          conscientiousness: 0.7,
          humorStyle: 'witty',
        );

        final json = traits.toJson();

        expect(json['openness'], 0.8);
        expect(json['conscientiousness'], 0.7);
        expect(json['humor_style'], 'witty');
      });

      test('fromJson handles null', () {
        final traits = PersonalityTraits.fromJson(null);

        expect(traits.openness, 0.5);
        expect(traits.humorStyle, isNull);
      });
    });

    group('OfflineAction', () {
      test('creates OfflineAction correctly', () {
        final action = OfflineAction(
          id: 'action-1',
          type: ActionType.sendMessage,
          payload: {'content': 'Hello'},
        );

        expect(action.id, 'action-1');
        expect(action.type, ActionType.sendMessage);
        expect(action.payload['content'], 'Hello');
        expect(action.retryCount, 0);
      });

      test('fromJson creates correct action', () {
        final json = {
          'id': 'action-1',
          'type': 'like_post',
          'payload': {'post_id': 'post-1'},
          'created_at': '2026-03-21T10:00:00Z',
          'retry_count': 2,
          'error_message': 'Network error',
        };

        final action = OfflineAction.fromJson(json);

        expect(action.id, 'action-1');
        expect(action.type, ActionType.likePost);
        expect(action.payload['post_id'], 'post-1');
        expect(action.retryCount, 2);
        expect(action.errorMessage, 'Network error');
      });

      test('toJson exports correct map', () {
        final action = OfflineAction(
          id: 'action-1',
          type: ActionType.createPost,
          payload: {'content': 'New post'},
        );

        final json = action.toJson();

        expect(json['id'], 'action-1');
        expect(json['type'], 'create_post');
        expect(json['payload']['content'], 'New post');
      });

      test('hasExceededRetries works correctly', () {
        final action = OfflineAction(
          id: 'action-1',
          type: ActionType.sendDm,
          payload: {},
        );

        expect(action.hasExceededRetries, false);

        action.incrementRetry();
        action.incrementRetry();
        expect(action.hasExceededRetries, false);

        action.incrementRetry();
        expect(action.hasExceededRetries, true);
      });

      test('serialize and deserialize work correctly', () {
        final action = OfflineAction(
          id: 'action-1',
          type: ActionType.createComment,
          payload: {'content': 'Comment'},
        );

        final serialized = action.serialize();
        final deserialized = OfflineAction.deserialize(serialized);

        expect(deserialized.id, action.id);
        expect(deserialized.type, action.type);
        expect(deserialized.payload['content'], 'Comment');
      });
    });

    group('ActionType', () {
      test('value extension returns correct strings', () {
        expect(ActionType.sendMessage.value, 'send_message');
        expect(ActionType.createPost.value, 'create_post');
        expect(ActionType.likePost.value, 'like_post');
        expect(ActionType.unlikePost.value, 'unlike_post');
        expect(ActionType.sendDm.value, 'send_dm');
        expect(ActionType.createComment.value, 'create_comment');
      });

      test('fromString parses correctly', () {
        expect(ActionTypeExtension.fromString('send_message'), ActionType.sendMessage);
        expect(ActionTypeExtension.fromString('create_post'), ActionType.createPost);
        expect(ActionTypeExtension.fromString('like_post'), ActionType.likePost);
      });

      test('fromString throws for unknown values', () {
        expect(
          () => ActionTypeExtension.fromString('unknown'),
          throwsArgumentError,
        );
      });
    });
  });
}
