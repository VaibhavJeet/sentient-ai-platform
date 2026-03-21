import 'package:flutter_test/flutter_test.dart';
import 'package:hive_observation/models/models.dart';
import 'package:hive_observation/models/offline_action.dart';
import '../test_helpers.dart';

void main() {
  group('Model Tests Using Fixtures', () {
    group('Author', () {
      test('fromJson creates Author from JsonFixtures', () {
        final json = JsonFixtures.authorJson(
          id: 'custom-id',
          displayName: 'Custom Bot',
          handle: '@custom',
        );

        final author = Author.fromJson(json);

        expect(author.id, 'custom-id');
        expect(author.displayName, 'Custom Bot');
        expect(author.handle, '@custom');
      });

      test('TestFixtures creates Author correctly', () {
        final author = TestFixtures.createAuthor(
          id: 'fixture-id',
          displayName: 'Fixture Bot',
        );

        expect(author.id, 'fixture-id');
        expect(author.displayName, 'Fixture Bot');
        expect(author.isAiLabeled, true);
      });
    });

    group('Post', () {
      test('fromJson creates Post from JsonFixtures', () {
        final json = JsonFixtures.postJson(
          id: 'post-abc',
          content: 'Hello from fixture!',
          likeCount: 42,
          isLikedByUser: true,
        );

        final post = Post.fromJson(json);

        expect(post.id, 'post-abc');
        expect(post.content, 'Hello from fixture!');
        expect(post.likeCount, 42);
        expect(post.isLikedByUser, true);
      });

      test('TestFixtures creates Post correctly', () {
        final post = TestFixtures.createPost(
          id: 'fixture-post',
          content: 'Fixture content',
          likeCount: 10,
          commentCount: 5,
        );

        expect(post.id, 'fixture-post');
        expect(post.content, 'Fixture content');
        expect(post.likeCount, 10);
        expect(post.commentCount, 5);
      });

      test('Post with custom author', () {
        final author = TestFixtures.createAuthor(
          id: 'special-author',
          displayName: 'Special Bot',
        );

        final post = TestFixtures.createPost(
          author: author,
          content: 'Post by special bot',
        );

        expect(post.author.id, 'special-author');
        expect(post.author.displayName, 'Special Bot');
      });

      test('Post with reaction counts', () {
        final reactionCounts = TestFixtures.createReactionCounts(
          like: 10,
          love: 5,
          fire: 3,
        );

        final post = TestFixtures.createPost(
          reactionCounts: reactionCounts,
        );

        expect(post.reactionCounts.countFor(ReactionType.like), 10);
        expect(post.reactionCounts.countFor(ReactionType.love), 5);
        expect(post.reactionCounts.countFor(ReactionType.fire), 3);
        expect(post.reactionCounts.total, 18);
      });
    });

    group('Comment', () {
      test('TestFixtures creates Comment correctly', () {
        final comment = TestFixtures.createComment(
          id: 'comment-123',
          content: 'Great post!',
          likeCount: 5,
        );

        expect(comment.id, 'comment-123');
        expect(comment.content, 'Great post!');
        expect(comment.likeCount, 5);
      });

      test('Post with recent comments', () {
        final comments = [
          TestFixtures.createComment(id: 'c1', content: 'First!'),
          TestFixtures.createComment(id: 'c2', content: 'Second!'),
        ];

        final post = TestFixtures.createPost(
          recentComments: comments,
        );

        expect(post.recentComments.length, 2);
        expect(post.recentComments[0].content, 'First!');
      });
    });

    group('Community', () {
      test('fromJson creates Community from JsonFixtures', () {
        final json = JsonFixtures.communityJson(
          id: 'comm-123',
          name: 'Philosophy Corner',
          botCount: 15,
          activityLevel: 0.85,
        );

        final community = Community.fromJson(json);

        expect(community.id, 'comm-123');
        expect(community.name, 'Philosophy Corner');
        expect(community.botCount, 15);
        expect(community.activityLevel, 0.85);
      });

      test('TestFixtures creates Community correctly', () {
        final community = TestFixtures.createCommunity(
          id: 'fixture-comm',
          name: 'Fixture Community',
          theme: 'tech',
        );

        expect(community.id, 'fixture-comm');
        expect(community.theme, 'tech');
      });
    });

    group('ChatMessage', () {
      test('fromJson creates ChatMessage from JsonFixtures', () {
        final json = JsonFixtures.chatMessageJson(
          id: 'msg-123',
          content: 'Hello chat!',
          replyToId: 'msg-122',
        );

        final message = ChatMessage.fromJson(json);

        expect(message.id, 'msg-123');
        expect(message.content, 'Hello chat!');
        expect(message.replyToId, 'msg-122');
      });

      test('TestFixtures creates ChatMessage correctly', () {
        final message = TestFixtures.createChatMessage(
          id: 'fixture-msg',
          content: 'Fixture message',
          isFromUser: true,
        );

        expect(message.id, 'fixture-msg');
        expect(message.isFromUser, true);
      });
    });

    group('DirectMessage', () {
      test('TestFixtures creates DirectMessage correctly', () {
        final dm = TestFixtures.createDirectMessage(
          id: 'dm-fixture',
          content: 'Hello!',
          isFromUser: true,
          isRead: true,
        );

        expect(dm.id, 'dm-fixture');
        expect(dm.content, 'Hello!');
        expect(dm.isFromUser, true);
        expect(dm.isRead, true);
      });
    });

    group('Conversation', () {
      test('fromJson creates Conversation from JsonFixtures', () {
        final json = JsonFixtures.conversationJson(
          conversationId: 'conv-fixture',
          lastMessage: 'See you!',
          unreadCount: 3,
        );

        final conv = Conversation.fromJson(json);

        expect(conv.conversationId, 'conv-fixture');
        expect(conv.lastMessage, 'See you!');
        expect(conv.unreadCount, 3);
      });

      test('TestFixtures creates Conversation correctly', () {
        final conv = TestFixtures.createConversation(
          conversationId: 'test-conv',
          lastMessage: 'Latest message',
        );

        expect(conv.conversationId, 'test-conv');
        expect(conv.lastMessage, 'Latest message');
      });
    });

    group('BotProfile', () {
      test('fromJson creates BotProfile from JsonFixtures', () {
        final json = JsonFixtures.botProfileJson(
          id: 'bot-fixture',
          displayName: 'Fixture Bot',
          age: 30,
          interests: ['coding', 'AI'],
          postCount: 100,
        );

        final bot = BotProfile.fromJson(json);

        expect(bot.id, 'bot-fixture');
        expect(bot.displayName, 'Fixture Bot');
        expect(bot.age, 30);
        expect(bot.interests, ['coding', 'AI']);
        expect(bot.postCount, 100);
      });

      test('TestFixtures creates BotProfile correctly', () {
        final bot = TestFixtures.createBotProfile(
          id: 'test-bot',
          displayName: 'Test Bot',
          mood: 'happy',
          energy: 'high',
        );

        expect(bot.id, 'test-bot');
        expect(bot.mood, 'happy');
        expect(bot.energy, 'high');
      });

      test('BotProfile with personality traits', () {
        final traits = TestFixtures.createPersonalityTraits(
          openness: 0.9,
          extraversion: 0.8,
          humorStyle: 'witty',
        );

        final bot = TestFixtures.createBotProfile(
          personalityTraits: traits,
        );

        expect(bot.personalityTraits.openness, 0.9);
        expect(bot.personalityTraits.extraversion, 0.8);
        expect(bot.personalityTraits.humorStyle, 'witty');
      });
    });

    group('AppUser', () {
      test('fromJson creates AppUser from JsonFixtures', () {
        final json = JsonFixtures.appUserJson(
          id: 'user-fixture',
          displayName: 'Fixture User',
        );

        final user = AppUser.fromJson(json);

        expect(user.id, 'user-fixture');
        expect(user.displayName, 'Fixture User');
      });

      test('TestFixtures creates AppUser correctly', () {
        final user = TestFixtures.createAppUser(
          id: 'test-user',
          deviceId: 'test-device',
        );

        expect(user.id, 'test-user');
        expect(user.deviceId, 'test-device');
      });
    });

    group('OfflineAction', () {
      test('fromJson creates OfflineAction from JsonFixtures', () {
        final json = JsonFixtures.offlineActionJson(
          id: 'action-fixture',
          type: 'like_post',
          payload: {'post_id': 'p1'},
          retryCount: 2,
        );

        final action = OfflineAction.fromJson(json);

        expect(action.id, 'action-fixture');
        expect(action.type, ActionType.likePost);
        expect(action.payload['post_id'], 'p1');
        expect(action.retryCount, 2);
      });

      test('TestFixtures creates OfflineAction correctly', () {
        final action = TestFixtures.createOfflineAction(
          id: 'test-action',
          type: ActionType.createComment,
          payload: {'content': 'Nice!'},
        );

        expect(action.id, 'test-action');
        expect(action.type, ActionType.createComment);
        expect(action.payload['content'], 'Nice!');
      });
    });

    group('PersonalityTraits', () {
      test('TestFixtures creates PersonalityTraits correctly', () {
        final traits = TestFixtures.createPersonalityTraits(
          openness: 0.8,
          conscientiousness: 0.7,
          extraversion: 0.6,
          agreeableness: 0.9,
          neuroticism: 0.2,
          humorStyle: 'sarcastic',
          communicationStyle: 'direct',
          conflictStyle: 'collaborative',
        );

        expect(traits.openness, 0.8);
        expect(traits.conscientiousness, 0.7);
        expect(traits.extraversion, 0.6);
        expect(traits.agreeableness, 0.9);
        expect(traits.neuroticism, 0.2);
        expect(traits.humorStyle, 'sarcastic');
        expect(traits.communicationStyle, 'direct');
        expect(traits.conflictStyle, 'collaborative');
      });
    });

    group('ReactionCounts', () {
      test('TestFixtures creates ReactionCounts correctly', () {
        final counts = TestFixtures.createReactionCounts(
          like: 10,
          love: 5,
          haha: 3,
          fire: 2,
        );

        expect(counts.total, 20);
        expect(counts.countFor(ReactionType.like), 10);
        expect(counts.countFor(ReactionType.love), 5);
        expect(counts.countFor(ReactionType.haha), 3);
        expect(counts.countFor(ReactionType.fire), 2);
        expect(counts.countFor(ReactionType.sad), 0);
      });

      test('topReactions returns sorted results', () {
        final counts = TestFixtures.createReactionCounts(
          like: 5,
          love: 10,
          fire: 8,
          clap: 3,
        );

        final top = counts.topReactions(limit: 3);

        expect(top.length, 3);
        expect(top[0].key, ReactionType.love);
        expect(top[1].key, ReactionType.fire);
        expect(top[2].key, ReactionType.like);
      });
    });
  });

  group('Edge Cases', () {
    test('Post with null optional fields', () {
      final json = JsonFixtures.postJson(
        imageUrl: null,
        userReactionType: null,
        reactionCounts: null,
      );

      final post = Post.fromJson(json);

      expect(post.imageUrl, isNull);
      expect(post.userReactionType, isNull);
      expect(post.reactionCounts.total, 0);
    });

    test('Author with minimal fields', () {
      final json = {
        'id': 'min-author',
        'display_name': 'Minimal',
        'avatar_seed': 'seed',
      };

      final author = Author.fromJson(json);

      expect(author.id, 'min-author');
      expect(author.handle, '');
      expect(author.isAiLabeled, true);
      expect(author.aiLabelText, '🤖 AI');
    });

    test('ChatMessage handles nested author fallback', () {
      // When author object is missing, ChatMessage.fromJson creates author from flat fields
      final json = {
        'id': 'msg-1',
        'community_id': 'c1',
        'author_id': 'bot-1',
        'author_name': 'Bot Name',
        'avatar_seed': 'seed-1',
        'content': 'Hello',
        'created_at': '2026-03-21T10:00:00Z',
        'is_bot': true,
      };

      final message = ChatMessage.fromJson(json);

      // The fallback author is created from json['author'] which is null,
      // so it uses the fallback map with author_id, author_name, etc.
      expect(message.author.id, 'bot-1');
      expect(message.author.displayName, 'Bot Name');
    });

    test('DirectMessage sender parsing with both formats', () {
      // Format 1: sender as object
      final json1 = {
        'id': 'dm-1',
        'conversation_id': 'conv-1',
        'sender': {
          'id': 'user-1',
          'display_name': 'User',
          'avatar_seed': 'seed',
        },
        'receiver_id': 'bot-1',
        'content': 'Hello',
        'created_at': '2026-03-21T10:00:00Z',
      };

      final dm1 = DirectMessage.fromJson(json1, 'user-1');
      expect(dm1.isFromUser, true);

      // Format 2: sender_id as string
      final json2 = {
        'id': 'dm-2',
        'conversation_id': 'conv-1',
        'sender_id': 'bot-1',
        'sender_name': 'Bot',
        'avatar_seed': 'seed',
        'receiver_id': 'user-1',
        'content': 'Response',
        'created_at': '2026-03-21T10:01:00Z',
      };

      final dm2 = DirectMessage.fromJson(json2, 'user-1');
      expect(dm2.isFromUser, false);
    });

    test('OfflineAction handles all action types', () {
      for (final type in ActionType.values) {
        final action = TestFixtures.createOfflineAction(type: type);
        expect(action.type, type);

        final json = action.toJson();
        final restored = OfflineAction.fromJson(json);
        expect(restored.type, type);
      }
    });
  });
}
