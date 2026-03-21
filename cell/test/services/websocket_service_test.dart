import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_observation/models/models.dart';

void main() {
  group('WebSocketService Message Parsing', () {
    group('handleNewPost parsing', () {
      test('parses new post event correctly', () {
        final data = {
          'post_id': 'post-123',
          'author_id': 'author-1',
          'author_name': 'Test Bot',
          'author_handle': '@testbot',
          'avatar_seed': 'seed-abc',
          'community_id': 'community-1',
          'community_name': 'Test Community',
          'content': 'Hello from WebSocket!',
        };

        final post = _parseNewPost(data);

        expect(post.id, 'post-123');
        expect(post.author.id, 'author-1');
        expect(post.author.displayName, 'Test Bot');
        expect(post.content, 'Hello from WebSocket!');
        expect(post.communityId, 'community-1');
      });

      test('handles missing fields gracefully', () {
        final data = {
          'post_id': 'post-123',
          'content': 'Minimal post',
        };

        final post = _parseNewPost(data);

        expect(post.id, 'post-123');
        expect(post.content, 'Minimal post');
        expect(post.author.displayName, 'Unknown');
      });
    });

    group('handlePostLiked parsing', () {
      test('parses post liked event correctly', () {
        final data = {
          'post_id': 'post-123',
          'liker_id': 'user-1',
          'liker_name': 'Test User',
          'like_count': 15,
        };

        final result = _parsePostLiked(data);

        expect(result['post_id'], 'post-123');
        expect(result['liker_id'], 'user-1');
        expect(result['like_count'], 15);
      });
    });

    group('handleNewComment parsing', () {
      test('parses new comment event correctly', () {
        final data = {
          'comment_id': 'comment-123',
          'author_id': 'author-1',
          'author_name': 'Commenter Bot',
          'avatar_seed': 'seed-1',
          'content': 'Great post!',
        };

        final comment = _parseNewComment(data);

        expect(comment.id, 'comment-123');
        expect(comment.author.displayName, 'Commenter Bot');
        expect(comment.content, 'Great post!');
      });
    });

    group('handleNewChatMessage parsing', () {
      test('parses chat message event correctly', () {
        final data = {
          'message_id': 'msg-123',
          'community_id': 'community-1',
          'author_id': 'bot-1',
          'author_name': 'Chat Bot',
          'avatar_seed': 'seed-1',
          'content': 'Hello everyone!',
          'is_bot': true,
        };

        final message = _parseChatMessage(data);

        expect(message.id, 'msg-123');
        expect(message.communityId, 'community-1');
        expect(message.content, 'Hello everyone!');
        expect(message.isFromUser, false);
      });

      test('handles user messages correctly', () {
        final data = {
          'message_id': 'msg-124',
          'community_id': 'community-1',
          'author_id': 'user-1',
          'author_name': 'Human User',
          'avatar_seed': 'seed-2',
          'content': 'Hi bots!',
          'is_bot': false,
        };

        final message = _parseChatMessage(data);

        expect(message.isFromUser, true);
      });
    });

    group('handleNewDm parsing', () {
      test('parses direct message event correctly', () {
        final data = {
          'message_id': 'dm-123',
          'conversation_id': 'conv-1',
          'sender_id': 'bot-1',
          'sender_name': 'Bot Friend',
          'avatar_seed': 'seed-1',
          'receiver_id': 'user-1',
          'content': 'Hello there!',
        };

        final dm = _parseDirectMessage(data);

        expect(dm.id, 'dm-123');
        expect(dm.conversationId, 'conv-1');
        expect(dm.content, 'Hello there!');
        expect(dm.isFromUser, false);
      });
    });

    group('Message routing', () {
      test('routes messages to correct handler based on type', () {
        final messages = <String, dynamic>{};

        void handleMessage(String jsonStr) {
          final data = jsonDecode(jsonStr);
          final type = data['type'] as String?;

          if (type == null) return;

          final eventData = data['data'] as Map<String, dynamic>? ?? data;

          switch (type) {
            case 'new_post':
              messages['new_post'] = eventData;
              break;
            case 'post_liked':
              messages['post_liked'] = eventData;
              break;
            case 'new_comment':
              messages['new_comment'] = eventData;
              break;
            case 'new_chat_message':
              messages['new_chat_message'] = eventData;
              break;
            case 'new_dm':
              messages['new_dm'] = eventData;
              break;
            case 'typing_start':
              messages['typing_start'] = eventData;
              break;
            case 'typing_stop':
              messages['typing_stop'] = eventData;
              break;
            case 'pong':
              messages['pong'] = true;
              break;
          }
        }

        handleMessage(jsonEncode({
          'type': 'new_post',
          'data': {'post_id': 'p1'},
        }));
        expect(messages['new_post'], isNotNull);
        expect(messages['new_post']['post_id'], 'p1');

        handleMessage(jsonEncode({
          'type': 'post_liked',
          'data': {'post_id': 'p1', 'like_count': 5},
        }));
        expect(messages['post_liked']['like_count'], 5);

        handleMessage(jsonEncode({
          'type': 'typing_start',
          'data': {'bot_id': 'bot-1'},
        }));
        expect(messages['typing_start']['bot_id'], 'bot-1');

        handleMessage(jsonEncode({'type': 'pong'}));
        expect(messages['pong'], true);
      });

      test('ignores messages without type', () {
        var handled = false;

        void handleMessage(String jsonStr) {
          final data = jsonDecode(jsonStr);
          final type = data['type'] as String?;
          if (type == null) return;
          handled = true;
        }

        handleMessage(jsonEncode({'data': 'no type'}));
        expect(handled, false);
      });
    });

    group('Message construction', () {
      test('constructs DM message correctly', () {
        final message = _constructDmMessage('bot-1', 'user-1', 'Hello!');

        expect(message['type'], 'dm');
        expect(message['bot_id'], 'bot-1');
        expect(message['user_id'], 'user-1');
        expect(message['content'], 'Hello!');
      });

      test('constructs chat message correctly', () {
        final message = _constructChatMessage('comm-1', 'user-1', 'Hi all!', replyToId: 'msg-1');

        expect(message['type'], 'chat');
        expect(message['community_id'], 'comm-1');
        expect(message['user_id'], 'user-1');
        expect(message['content'], 'Hi all!');
        expect(message['reply_to_id'], 'msg-1');
      });

      test('constructs subscribe message correctly', () {
        final message = _constructSubscribeMessage('comm-1');

        expect(message['type'], 'subscribe');
        expect(message['community_id'], 'comm-1');
      });

      test('constructs ping message correctly', () {
        final message = _constructPingMessage();

        expect(message['type'], 'ping');
      });
    });

    group('Event callback registration', () {
      test('registers and calls event handlers', () {
        final handlers = <String, List<Function(Map<String, dynamic>)>>{};
        var callCount = 0;
        Map<String, dynamic>? receivedData;

        void on(String event, Function(Map<String, dynamic>) callback) {
          handlers.putIfAbsent(event, () => []).add(callback);
        }

        void emit(String event, Map<String, dynamic> data) {
          handlers[event]?.forEach((handler) => handler(data));
        }

        on('custom_event', (data) {
          callCount++;
          receivedData = data;
        });

        emit('custom_event', {'key': 'value'});

        expect(callCount, 1);
        expect(receivedData?['key'], 'value');
      });

      test('supports multiple handlers for same event', () {
        final handlers = <String, List<Function(Map<String, dynamic>)>>{};
        var handler1Called = false;
        var handler2Called = false;

        void on(String event, Function(Map<String, dynamic>) callback) {
          handlers.putIfAbsent(event, () => []).add(callback);
        }

        void emit(String event, Map<String, dynamic> data) {
          handlers[event]?.forEach((handler) => handler(data));
        }

        on('event', (_) => handler1Called = true);
        on('event', (_) => handler2Called = true);

        emit('event', {});

        expect(handler1Called, true);
        expect(handler2Called, true);
      });

      test('off removes event handler', () {
        final handlers = <String, List<Function(Map<String, dynamic>)>>{};
        var callCount = 0;

        void handler(Map<String, dynamic> data) {
          callCount++;
        }

        void on(String event, Function(Map<String, dynamic>) callback) {
          handlers.putIfAbsent(event, () => []).add(callback);
        }

        void off(String event, Function(Map<String, dynamic>) callback) {
          handlers[event]?.remove(callback);
        }

        void emit(String event, Map<String, dynamic> data) {
          handlers[event]?.forEach((h) => h(data));
        }

        on('event', handler);
        emit('event', {});
        expect(callCount, 1);

        off('event', handler);
        emit('event', {});
        expect(callCount, 1); // Should not increment
      });
    });

    group('Reconnection logic', () {
      test('calculates exponential backoff correctly', () {
        int calculateDelay(int attempts) {
          const baseDelay = 1;
          return (baseDelay * (1 << attempts)).clamp(1, 30);
        }

        expect(calculateDelay(0), 1);
        expect(calculateDelay(1), 2);
        expect(calculateDelay(2), 4);
        expect(calculateDelay(3), 8);
        expect(calculateDelay(4), 16);
        expect(calculateDelay(5), 30); // Clamped to max
        expect(calculateDelay(10), 30); // Still clamped
      });

      test('respects max reconnect attempts', () {
        const maxAttempts = 10;
        var attempts = 0;
        var gaveUp = false;

        void scheduleReconnect() {
          if (attempts >= maxAttempts) {
            gaveUp = true;
            return;
          }
          attempts++;
        }

        for (var i = 0; i < 15; i++) {
          scheduleReconnect();
        }

        expect(attempts, maxAttempts);
        expect(gaveUp, true);
      });
    });

    group('Connection state', () {
      test('connection state stream emits correct values', () async {
        final controller = StreamController<bool>.broadcast();
        final states = <bool>[];

        controller.stream.listen(states.add);

        controller.add(true);
        controller.add(false);
        controller.add(true);

        await Future.delayed(Duration.zero);

        expect(states, [true, false, true]);

        await controller.close();
      });
    });

    group('Stream controllers', () {
      test('new post stream emits posts', () async {
        final controller = StreamController<Post>.broadcast();
        Post? receivedPost;

        controller.stream.listen((post) {
          receivedPost = post;
        });

        final testPost = Post(
          id: 'test-1',
          author: Author(id: 'a1', displayName: 'Bot', avatarSeed: 's1'),
          communityId: 'c1',
          communityName: 'Test',
          content: 'Test content',
          createdAt: DateTime.now(),
        );

        controller.add(testPost);

        await Future.delayed(Duration.zero);

        expect(receivedPost, isNotNull);
        expect(receivedPost!.id, 'test-1');

        await controller.close();
      });

      test('typing stream emits bot IDs', () async {
        final controller = StreamController<String>.broadcast();
        final typingEvents = <String>[];

        controller.stream.listen(typingEvents.add);

        controller.add('bot-1');
        controller.add('');
        controller.add('bot-2');

        await Future.delayed(Duration.zero);

        expect(typingEvents, ['bot-1', '', 'bot-2']);

        await controller.close();
      });
    });
  });
}

// Helper functions that mirror WebSocketService logic

Post _parseNewPost(Map<String, dynamic> data) {
  return Post(
    id: data['post_id'] ?? '',
    author: Author(
      id: data['author_id'] ?? '',
      displayName: data['author_name'] ?? 'Unknown',
      handle: data['author_handle'] ?? '',
      avatarSeed: data['avatar_seed'] ?? '',
    ),
    communityId: data['community_id'] ?? '',
    communityName: data['community_name'] ?? '',
    content: data['content'] ?? '',
    createdAt: DateTime.now(),
  );
}

Map<String, dynamic> _parsePostLiked(Map<String, dynamic> data) {
  return {
    'post_id': data['post_id'],
    'liker_id': data['liker_id'],
    'liker_name': data['liker_name'],
    'like_count': data['like_count'],
  };
}

Comment _parseNewComment(Map<String, dynamic> data) {
  return Comment(
    id: data['comment_id'] ?? '',
    author: Author(
      id: data['author_id'] ?? '',
      displayName: data['author_name'] ?? 'Unknown',
      avatarSeed: data['avatar_seed'] ?? '',
    ),
    content: data['content'] ?? '',
    createdAt: DateTime.now(),
  );
}

ChatMessage _parseChatMessage(Map<String, dynamic> data) {
  return ChatMessage(
    id: data['message_id'] ?? '',
    communityId: data['community_id'] ?? '',
    author: Author(
      id: data['author_id'] ?? '',
      displayName: data['author_name'] ?? 'Unknown',
      avatarSeed: data['avatar_seed'] ?? '',
      isAiLabeled: data['is_bot'] ?? true,
    ),
    content: data['content'] ?? '',
    createdAt: DateTime.now(),
    isFromUser: !(data['is_bot'] ?? true),
  );
}

DirectMessage _parseDirectMessage(Map<String, dynamic> data) {
  return DirectMessage(
    id: data['message_id'] ?? '',
    conversationId: data['conversation_id'] ?? '',
    sender: Author(
      id: data['sender_id'] ?? '',
      displayName: data['sender_name'] ?? 'Unknown',
      avatarSeed: data['avatar_seed'] ?? '',
    ),
    receiverId: data['receiver_id'] ?? '',
    content: data['content'] ?? '',
    createdAt: DateTime.now(),
    isFromUser: false,
  );
}

Map<String, dynamic> _constructDmMessage(String botId, String userId, String content) {
  return {
    'type': 'dm',
    'bot_id': botId,
    'user_id': userId,
    'content': content,
  };
}

Map<String, dynamic> _constructChatMessage(String communityId, String userId, String content, {String? replyToId}) {
  return {
    'type': 'chat',
    'community_id': communityId,
    'user_id': userId,
    'content': content,
    'reply_to_id': replyToId,
  };
}

Map<String, dynamic> _constructSubscribeMessage(String communityId) {
  return {
    'type': 'subscribe',
    'community_id': communityId,
  };
}

Map<String, dynamic> _constructPingMessage() {
  return {'type': 'ping'};
}
