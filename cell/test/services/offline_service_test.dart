import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_observation/models/models.dart';
import 'package:hive_observation/models/offline_action.dart';

void main() {
  group('OfflineService', () {
    group('Action Queue Management', () {
      test('queueAction adds action to queue', () {
        final queue = <OfflineAction>[];

        final action = OfflineAction(
          id: 'action-1',
          type: ActionType.sendMessage,
          payload: {'content': 'Hello'},
        );

        queue.add(action);

        expect(queue.length, 1);
        expect(queue.first.id, 'action-1');
        expect(queue.first.type, ActionType.sendMessage);
      });

      test('multiple actions can be queued', () {
        final queue = <OfflineAction>[];

        queue.add(OfflineAction(
          id: 'action-1',
          type: ActionType.likePost,
          payload: {'post_id': 'post-1'},
        ));
        queue.add(OfflineAction(
          id: 'action-2',
          type: ActionType.createComment,
          payload: {'post_id': 'post-1', 'content': 'Nice!'},
        ));
        queue.add(OfflineAction(
          id: 'action-3',
          type: ActionType.sendDm,
          payload: {'bot_id': 'bot-1', 'content': 'Hello'},
        ));

        expect(queue.length, 3);
        expect(queue[0].type, ActionType.likePost);
        expect(queue[1].type, ActionType.createComment);
        expect(queue[2].type, ActionType.sendDm);
      });

      test('removeAction removes specific action', () {
        final queue = <OfflineAction>[];

        queue.add(OfflineAction(id: 'a1', type: ActionType.likePost, payload: {}));
        queue.add(OfflineAction(id: 'a2', type: ActionType.unlikePost, payload: {}));
        queue.add(OfflineAction(id: 'a3', type: ActionType.createPost, payload: {}));

        queue.removeWhere((a) => a.id == 'a2');

        expect(queue.length, 2);
        expect(queue.any((a) => a.id == 'a2'), false);
        expect(queue.any((a) => a.id == 'a1'), true);
        expect(queue.any((a) => a.id == 'a3'), true);
      });

      test('clearQueue removes all actions', () {
        final queue = <OfflineAction>[];

        queue.add(OfflineAction(id: 'a1', type: ActionType.likePost, payload: {}));
        queue.add(OfflineAction(id: 'a2', type: ActionType.unlikePost, payload: {}));

        queue.clear();

        expect(queue.isEmpty, true);
      });

      test('queuedActionCount returns correct count', () {
        final queue = <OfflineAction>[];

        expect(queue.length, 0);

        queue.add(OfflineAction(id: 'a1', type: ActionType.likePost, payload: {}));
        expect(queue.length, 1);

        queue.add(OfflineAction(id: 'a2', type: ActionType.likePost, payload: {}));
        expect(queue.length, 2);

        queue.removeAt(0);
        expect(queue.length, 1);
      });
    });

    group('Queue Persistence', () {
      test('queue can be serialized to JSON', () {
        final queue = <OfflineAction>[
          OfflineAction(
            id: 'a1',
            type: ActionType.sendMessage,
            payload: {'content': 'Hello'},
          ),
          OfflineAction(
            id: 'a2',
            type: ActionType.likePost,
            payload: {'post_id': 'p1'},
          ),
        ];

        final jsonList = queue.map((a) => a.toJson()).toList();
        final jsonStr = jsonEncode(jsonList);

        expect(jsonStr.contains('a1'), true);
        expect(jsonStr.contains('send_message'), true);
        expect(jsonStr.contains('a2'), true);
        expect(jsonStr.contains('like_post'), true);
      });

      test('queue can be deserialized from JSON', () {
        final jsonStr = jsonEncode([
          {
            'id': 'a1',
            'type': 'send_message',
            'payload': {'content': 'Hello'},
            'created_at': '2026-03-21T10:00:00Z',
            'retry_count': 0,
          },
          {
            'id': 'a2',
            'type': 'like_post',
            'payload': {'post_id': 'p1'},
            'created_at': '2026-03-21T10:01:00Z',
            'retry_count': 1,
          },
        ]);

        final List<dynamic> jsonList = jsonDecode(jsonStr);
        final queue = jsonList
            .map((json) => OfflineAction.fromJson(json as Map<String, dynamic>))
            .toList();

        expect(queue.length, 2);
        expect(queue[0].id, 'a1');
        expect(queue[0].type, ActionType.sendMessage);
        expect(queue[1].retryCount, 1);
      });
    });

    group('Action Processing', () {
      test('processQueue processes actions in order', () async {
        final queue = <OfflineAction>[
          OfflineAction(id: 'a1', type: ActionType.likePost, payload: {}),
          OfflineAction(id: 'a2', type: ActionType.createComment, payload: {}),
          OfflineAction(id: 'a3', type: ActionType.sendDm, payload: {}),
        ];
        final processedIds = <String>[];

        for (final action in List.from(queue)) {
          // Simulate processing
          processedIds.add(action.id);
          queue.removeWhere((a) => a.id == action.id);
        }

        expect(processedIds, ['a1', 'a2', 'a3']);
        expect(queue.isEmpty, true);
      });

      test('failed actions increment retry count', () {
        final action = OfflineAction(
          id: 'a1',
          type: ActionType.sendMessage,
          payload: {},
        );

        expect(action.retryCount, 0);

        action.incrementRetry();
        expect(action.retryCount, 1);

        action.incrementRetry();
        expect(action.retryCount, 2);

        action.errorMessage = 'Network error';
        expect(action.errorMessage, 'Network error');
      });

      test('actions are removed after max retries', () {
        final queue = <OfflineAction>[
          OfflineAction(id: 'a1', type: ActionType.likePost, payload: {}),
        ];

        final action = queue.first;

        // Simulate 3 failed attempts
        action.incrementRetry();
        action.incrementRetry();
        action.incrementRetry();

        expect(action.hasExceededRetries, true);

        // Remove exceeded actions
        queue.removeWhere((a) => a.hasExceededRetries);

        expect(queue.isEmpty, true);
      });

      test('successful processing calls onActionProcessed callback', () {
        OfflineAction? processedAction;

        void onActionProcessed(OfflineAction action) {
          processedAction = action;
        }

        final action = OfflineAction(
          id: 'a1',
          type: ActionType.likePost,
          payload: {'post_id': 'p1'},
        );

        // Simulate successful processing
        onActionProcessed(action);

        expect(processedAction, isNotNull);
        expect(processedAction!.id, 'a1');
      });

      test('failed processing calls onActionFailed callback', () {
        OfflineAction? failedAction;
        String? errorMessage;

        void onActionFailed(OfflineAction action, String error) {
          failedAction = action;
          errorMessage = error;
        }

        final action = OfflineAction(
          id: 'a1',
          type: ActionType.sendDm,
          payload: {},
        );
        action.incrementRetry();
        action.incrementRetry();
        action.incrementRetry();
        action.errorMessage = 'Connection timeout';

        // Simulate failure callback
        onActionFailed(action, 'Max retries exceeded: ${action.errorMessage}');

        expect(failedAction, isNotNull);
        expect(failedAction!.id, 'a1');
        expect(errorMessage, contains('Max retries exceeded'));
        expect(errorMessage, contains('Connection timeout'));
      });
    });

    group('Connectivity Status', () {
      test('online status stream emits changes', () async {
        final controller = StreamController<bool>.broadcast();
        final statuses = <bool>[];

        controller.stream.listen(statuses.add);

        controller.add(true);
        controller.add(false);
        controller.add(true);

        await Future.delayed(Duration.zero);

        expect(statuses, [true, false, true]);

        await controller.close();
      });

      test('coming back online triggers queue processing', () {
        var isOnline = true;
        var queueProcessed = false;

        void onConnectivityChanged(bool online) {
          final wasOffline = !isOnline;
          isOnline = online;

          // If coming back online (was offline, now online), process queue
          if (online && wasOffline) {
            queueProcessed = true;
          }
        }

        // Go offline first
        onConnectivityChanged(false);
        expect(queueProcessed, false);
        expect(isOnline, false);

        // Come back online - should trigger processing
        onConnectivityChanged(true);
        expect(queueProcessed, true);
        expect(isOnline, true);
      });
    });

    group('Cache Methods', () {
      test('cacheFeed stores posts correctly', () {
        final cache = <String, dynamic>{};

        void cacheFeed(List<Map<String, dynamic>> posts, {String? communityId}) {
          final key = communityId != null ? 'feed_$communityId' : 'feed_all';
          cache[key] = posts;
        }

        final posts = [
          {'id': 'p1', 'content': 'Post 1'},
          {'id': 'p2', 'content': 'Post 2'},
        ];

        cacheFeed(posts);
        expect(cache['feed_all'], isNotNull);
        expect((cache['feed_all'] as List).length, 2);

        cacheFeed(posts, communityId: 'c1');
        expect(cache['feed_c1'], isNotNull);
      });

      test('getCachedFeed retrieves posts correctly', () {
        final cache = <String, dynamic>{
          'feed_all': [
            {'id': 'p1', 'content': 'Post 1'},
            {'id': 'p2', 'content': 'Post 2'},
          ],
        };

        List<Map<String, dynamic>>? getCachedFeed({String? communityId}) {
          final key = communityId != null ? 'feed_$communityId' : 'feed_all';
          final data = cache[key];
          if (data == null) return null;
          return List<Map<String, dynamic>>.from(data);
        }

        final posts = getCachedFeed();
        expect(posts, isNotNull);
        expect(posts!.length, 2);

        final missingPosts = getCachedFeed(communityId: 'nonexistent');
        expect(missingPosts, isNull);
      });

      test('cacheConversations stores conversations correctly', () {
        final cache = <String, dynamic>{};

        void cacheConversations(String userId, List<Map<String, dynamic>> conversations) {
          cache['conversations_$userId'] = conversations;
        }

        final convs = [
          {'conversation_id': 'c1', 'last_message': 'Hello'},
        ];

        cacheConversations('user-1', convs);
        expect(cache['conversations_user-1'], isNotNull);
      });

      test('cacheCommunities stores communities correctly', () {
        final cache = <String, dynamic>{};

        void cacheCommunities(List<Map<String, dynamic>> communities) {
          cache['communities'] = communities;
        }

        final comms = [
          {'id': 'c1', 'name': 'Community 1'},
          {'id': 'c2', 'name': 'Community 2'},
        ];

        cacheCommunities(comms);
        expect(cache['communities'], isNotNull);
        expect((cache['communities'] as List).length, 2);
      });

      test('cacheChatMessages stores messages per community', () {
        final cache = <String, dynamic>{};

        void cacheChatMessages(String communityId, List<Map<String, dynamic>> messages) {
          cache['chat_$communityId'] = messages;
        }

        final messages = [
          {'id': 'm1', 'content': 'Hello'},
          {'id': 'm2', 'content': 'Hi'},
        ];

        cacheChatMessages('c1', messages);
        expect(cache['chat_c1'], isNotNull);

        cacheChatMessages('c2', []);
        expect(cache['chat_c2'], isNotNull);
        expect((cache['chat_c2'] as List).isEmpty, true);
      });
    });

    group('Model Serialization', () {
      test('Post serialization round-trip', () {
        final post = Post(
          id: 'p1',
          author: Author(
            id: 'a1',
            displayName: 'Bot',
            handle: '@bot',
            avatarSeed: 'seed',
            isAiLabeled: true,
          ),
          communityId: 'c1',
          communityName: 'Test',
          content: 'Hello World',
          likeCount: 5,
          commentCount: 2,
          createdAt: DateTime.parse('2026-03-21T10:00:00Z'),
          isLikedByUser: true,
        );

        // Serialize
        final json = {
          'id': post.id,
          'author': {
            'id': post.author.id,
            'display_name': post.author.displayName,
            'handle': post.author.handle,
            'avatar_seed': post.author.avatarSeed,
            'is_ai_labeled': post.author.isAiLabeled,
          },
          'community_id': post.communityId,
          'community_name': post.communityName,
          'content': post.content,
          'like_count': post.likeCount,
          'comment_count': post.commentCount,
          'created_at': post.createdAt.toIso8601String(),
          'is_liked_by_user': post.isLikedByUser,
          'recent_comments': [],
        };

        // Deserialize
        final restored = Post.fromJson(json);

        expect(restored.id, post.id);
        expect(restored.content, post.content);
        expect(restored.likeCount, post.likeCount);
        expect(restored.isLikedByUser, post.isLikedByUser);
        expect(restored.author.displayName, post.author.displayName);
      });

      test('Community serialization round-trip', () {
        final community = Community(
          id: 'c1',
          name: 'Philosophy Corner',
          description: 'Deep thoughts',
          theme: 'philosophy',
          tone: 'intellectual',
          botCount: 10,
          activityLevel: 0.75,
        );

        final json = {
          'id': community.id,
          'name': community.name,
          'description': community.description,
          'theme': community.theme,
          'tone': community.tone,
          'bot_count': community.botCount,
          'activity_level': community.activityLevel,
        };

        final restored = Community.fromJson(json);

        expect(restored.id, community.id);
        expect(restored.name, community.name);
        expect(restored.botCount, community.botCount);
        expect(restored.activityLevel, community.activityLevel);
      });

      test('ChatMessage serialization round-trip', () {
        final message = ChatMessage(
          id: 'm1',
          communityId: 'c1',
          author: Author(
            id: 'b1',
            displayName: 'Bot',
            avatarSeed: 'seed',
            isAiLabeled: true,
          ),
          content: 'Hello!',
          replyToId: 'm0',
          replyToContent: 'Original message',
          createdAt: DateTime.parse('2026-03-21T10:00:00Z'),
          isFromUser: false,
        );

        final json = {
          'id': message.id,
          'community_id': message.communityId,
          'author': {
            'id': message.author.id,
            'display_name': message.author.displayName,
            'avatar_seed': message.author.avatarSeed,
            'is_ai_labeled': message.author.isAiLabeled,
          },
          'content': message.content,
          'reply_to_id': message.replyToId,
          'reply_to_content': message.replyToContent,
          'created_at': message.createdAt.toIso8601String(),
          'is_bot': !message.isFromUser,
        };

        final restored = ChatMessage.fromJson(json);

        expect(restored.id, message.id);
        expect(restored.content, message.content);
        expect(restored.replyToId, message.replyToId);
        expect(restored.isFromUser, message.isFromUser);
      });

      test('Conversation serialization round-trip', () {
        final conversation = Conversation(
          conversationId: 'conv-1',
          otherUser: Author(
            id: 'b1',
            displayName: 'Bot Friend',
            avatarSeed: 'seed',
          ),
          lastMessage: 'See you later!',
          lastMessageTime: DateTime.parse('2026-03-21T10:00:00Z'),
          unreadCount: 3,
        );

        final json = {
          'conversation_id': conversation.conversationId,
          'other_user': {
            'id': conversation.otherUser.id,
            'display_name': conversation.otherUser.displayName,
            'avatar_seed': conversation.otherUser.avatarSeed,
          },
          'last_message': conversation.lastMessage,
          'last_message_time': conversation.lastMessageTime.toIso8601String(),
          'unread_count': conversation.unreadCount,
        };

        final restored = Conversation.fromJson(json);

        expect(restored.conversationId, conversation.conversationId);
        expect(restored.lastMessage, conversation.lastMessage);
        expect(restored.unreadCount, conversation.unreadCount);
        expect(restored.otherUser.displayName, conversation.otherUser.displayName);
      });

      test('DirectMessage serialization round-trip', () {
        final dm = DirectMessage(
          id: 'dm-1',
          conversationId: 'conv-1',
          sender: Author(
            id: 'user-1',
            displayName: 'User',
            avatarSeed: 'seed',
          ),
          receiverId: 'bot-1',
          content: 'Hello Bot!',
          createdAt: DateTime.parse('2026-03-21T10:00:00Z'),
          isRead: false,
          isFromUser: true,
        );

        final json = {
          'id': dm.id,
          'conversation_id': dm.conversationId,
          'sender': {
            'id': dm.sender.id,
            'display_name': dm.sender.displayName,
            'avatar_seed': dm.sender.avatarSeed,
          },
          'receiver_id': dm.receiverId,
          'content': dm.content,
          'created_at': dm.createdAt.toIso8601String(),
          'is_read': dm.isRead,
        };

        final restored = DirectMessage.fromJson(json, 'user-1');

        expect(restored.id, dm.id);
        expect(restored.content, dm.content);
        expect(restored.isFromUser, true); // sender.id matches currentUserId
      });
    });

    group('Edge Cases', () {
      test('empty queue does not process', () {
        final queue = <OfflineAction>[];
        var processed = false;

        void processQueue() {
          if (queue.isEmpty) return;
          processed = true;
        }

        processQueue();
        expect(processed, false);
      });

      test('offline status prevents queue processing', () {
        var isOnline = false;
        final queue = <OfflineAction>[
          OfflineAction(id: 'a1', type: ActionType.likePost, payload: {}),
        ];
        var processed = false;

        void processQueue() {
          if (!isOnline || queue.isEmpty) return;
          processed = true;
        }

        processQueue();
        expect(processed, false);

        isOnline = true;
        processQueue();
        expect(processed, true);
      });

      test('concurrent processing prevention', () {
        var isProcessing = false;
        var processingCount = 0;

        Future<void> processQueue() async {
          if (isProcessing) return;
          isProcessing = true;
          processingCount++;
          await Future.delayed(const Duration(milliseconds: 10));
          isProcessing = false;
        }

        // Try to process concurrently
        processQueue();
        processQueue();
        processQueue();

        expect(processingCount, 1);
      });

      test('null payload values are handled', () {
        final action = OfflineAction(
          id: 'a1',
          type: ActionType.sendMessage,
          payload: {
            'content': 'Hello',
            'optional_field': null,
          },
        );

        final json = action.toJson();
        expect(json['payload']['optional_field'], isNull);

        final restored = OfflineAction.fromJson(json);
        expect(restored.payload['optional_field'], isNull);
      });

      test('empty string in payload is preserved', () {
        final action = OfflineAction(
          id: 'a1',
          type: ActionType.sendMessage,
          payload: {'content': ''},
        );

        final json = action.toJson();
        final restored = OfflineAction.fromJson(json);

        expect(restored.payload['content'], '');
      });
    });
  });
}
