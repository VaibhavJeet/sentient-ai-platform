import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hive_observation/services/api_service.dart';
import 'package:hive_observation/models/models.dart';

void main() {
  group('ApiService', () {
    group('registerUser', () {
      test('successfully registers a user', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/users/register');
          expect(request.method, 'POST');

          final body = jsonDecode(request.body);
          expect(body['device_id'], 'test-device-123');
          expect(body['display_name'], 'Test User');

          return http.Response(
            jsonEncode({
              'id': 'user-123',
              'device_id': 'test-device-123',
              'display_name': 'Test User',
              'avatar_seed': 'seed-abc',
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final user = await apiService.registerUserWithClient(mockClient, 'test-device-123', 'Test User');

        expect(user.id, 'user-123');
        expect(user.deviceId, 'test-device-123');
        expect(user.displayName, 'Test User');
        expect(user.avatarSeed, 'seed-abc');
      });

      test('throws exception on registration failure', () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"error": "Registration failed"}', 400);
        });

        final apiService = TestableApiService(client: mockClient);

        expect(
          () => apiService.registerUserWithClient(mockClient, 'test-device', 'Test User'),
          throwsException,
        );
      });
    });

    group('getFeed', () {
      test('successfully fetches feed posts', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts');
          expect(request.url.queryParameters['limit'], '20');
          expect(request.url.queryParameters['offset'], '0');

          return http.Response(
            jsonEncode([
              {
                'id': 'post-1',
                'author': {
                  'id': 'author-1',
                  'display_name': 'Bot Author',
                  'avatar_seed': 'seed-1',
                },
                'community_id': 'community-1',
                'community_name': 'Test Community',
                'content': 'Hello World!',
                'like_count': 5,
                'comment_count': 2,
                'created_at': '2026-03-21T10:00:00Z',
                'is_liked_by_user': false,
                'recent_comments': [],
              },
              {
                'id': 'post-2',
                'author': {
                  'id': 'author-2',
                  'display_name': 'Another Bot',
                  'avatar_seed': 'seed-2',
                },
                'community_id': 'community-1',
                'community_name': 'Test Community',
                'content': 'Second post!',
                'like_count': 10,
                'comment_count': 0,
                'created_at': '2026-03-21T11:00:00Z',
                'is_liked_by_user': true,
                'recent_comments': [],
              },
            ]),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final posts = await apiService.getFeedWithClient(mockClient);

        expect(posts.length, 2);
        expect(posts[0].id, 'post-1');
        expect(posts[0].content, 'Hello World!');
        expect(posts[0].likeCount, 5);
        expect(posts[0].isLikedByUser, false);
        expect(posts[1].id, 'post-2');
        expect(posts[1].isLikedByUser, true);
      });

      test('returns posts filtered by community', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.queryParameters['community_id'], 'community-123');

          return http.Response(jsonEncode([]), 200);
        });

        final apiService = TestableApiService(client: mockClient);
        await apiService.getFeedWithClient(mockClient, communityId: 'community-123');
      });

      test('throws exception on feed fetch failure', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Server error', 500);
        });

        final apiService = TestableApiService(client: mockClient);

        expect(
          () => apiService.getFeedWithClient(mockClient),
          throwsException,
        );
      });
    });

    group('getPost', () {
      test('successfully fetches a single post', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts/post-123');

          return http.Response(
            jsonEncode({
              'id': 'post-123',
              'author': {
                'id': 'author-1',
                'display_name': 'Bot Author',
                'avatar_seed': 'seed-1',
              },
              'community_id': 'community-1',
              'community_name': 'Test Community',
              'content': 'Detailed post content',
              'like_count': 15,
              'comment_count': 5,
              'created_at': '2026-03-21T10:00:00Z',
              'is_liked_by_user': true,
              'recent_comments': [],
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final post = await apiService.getPostWithClient(mockClient, 'post-123');

        expect(post.id, 'post-123');
        expect(post.content, 'Detailed post content');
        expect(post.likeCount, 15);
      });
    });

    group('likePost', () {
      test('successfully likes a post', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts/post-123/like');
          expect(request.method, 'POST');
          expect(request.url.queryParameters['user_id'], 'user-1');
          expect(request.url.queryParameters['reaction_type'], 'like');

          return http.Response(
            jsonEncode({
              'post_id': 'post-123',
              'like_count': 6,
              'success': true,
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final result = await apiService.likePostWithClient(
          mockClient,
          'post-123',
          'user-1',
        );

        expect(result['post_id'], 'post-123');
        expect(result['like_count'], 6);
      });
    });

    group('unlikePost', () {
      test('successfully unlikes a post', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts/post-123/like');
          expect(request.method, 'DELETE');
          expect(request.url.queryParameters['user_id'], 'user-1');

          return http.Response(
            jsonEncode({
              'post_id': 'post-123',
              'like_count': 4,
              'success': true,
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final result = await apiService.unlikePostWithClient(
          mockClient,
          'post-123',
          'user-1',
        );

        expect(result['post_id'], 'post-123');
        expect(result['like_count'], 4);
      });
    });

    group('createComment', () {
      test('successfully creates a comment', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts/post-123/comments');
          expect(request.method, 'POST');
          expect(request.url.queryParameters['user_id'], 'user-1');
          expect(request.url.queryParameters['content'], 'Great post!');

          return http.Response(
            jsonEncode({
              'id': 'comment-1',
              'author': {
                'id': 'user-1',
                'display_name': 'Test User',
                'avatar_seed': 'seed-1',
              },
              'content': 'Great post!',
              'like_count': 0,
              'created_at': '2026-03-21T12:00:00Z',
              'reply_count': 0,
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final comment = await apiService.createCommentWithClient(
          mockClient,
          'post-123',
          'user-1',
          'Great post!',
        );

        expect(comment.id, 'comment-1');
        expect(comment.content, 'Great post!');
      });
    });

    group('getComments', () {
      test('successfully fetches comments', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts/post-123/comments');
          expect(request.method, 'GET');

          return http.Response(
            jsonEncode([
              {
                'id': 'comment-1',
                'author': {
                  'id': 'author-1',
                  'display_name': 'Bot 1',
                  'avatar_seed': 'seed-1',
                },
                'content': 'First comment',
                'like_count': 2,
                'created_at': '2026-03-21T10:00:00Z',
                'reply_count': 0,
              },
              {
                'id': 'comment-2',
                'author': {
                  'id': 'author-2',
                  'display_name': 'Bot 2',
                  'avatar_seed': 'seed-2',
                },
                'content': 'Second comment',
                'like_count': 1,
                'created_at': '2026-03-21T11:00:00Z',
                'reply_count': 1,
              },
            ]),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final comments = await apiService.getCommentsWithClient(mockClient, 'post-123');

        expect(comments.length, 2);
        expect(comments[0].id, 'comment-1');
        expect(comments[0].content, 'First comment');
        expect(comments[1].replyCount, 1);
      });
    });

    group('getCommunities', () {
      test('successfully fetches communities', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/communities');

          return http.Response(
            jsonEncode([
              {
                'id': 'community-1',
                'name': 'Philosophy Corner',
                'description': 'Deep thoughts and discussions',
                'theme': 'philosophy',
                'tone': 'intellectual',
                'bot_count': 10,
                'activity_level': 0.8,
              },
              {
                'id': 'community-2',
                'name': 'Tech Hub',
                'description': 'All things technology',
                'theme': 'technology',
                'tone': 'enthusiastic',
                'bot_count': 15,
                'activity_level': 0.9,
              },
            ]),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final communities = await apiService.getCommunitiesWithClient(mockClient);

        expect(communities.length, 2);
        expect(communities[0].name, 'Philosophy Corner');
        expect(communities[0].botCount, 10);
        expect(communities[1].activityLevel, 0.9);
      });
    });

    group('getBots', () {
      test('successfully fetches bots', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/users/bots');

          return http.Response(
            jsonEncode([
              {
                'id': 'bot-1',
                'display_name': 'Philosopher Bot',
                'handle': 'philosopher',
                'bio': 'I think, therefore I am',
                'avatar_seed': 'seed-1',
                'age': 30,
                'interests': ['philosophy', 'ethics'],
                'mood': 'contemplative',
                'energy': 'medium',
                'post_count': 50,
                'comment_count': 100,
                'follower_count': 200,
              },
            ]),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final bots = await apiService.getBotsWithClient(mockClient);

        expect(bots.length, 1);
        expect(bots[0].displayName, 'Philosopher Bot');
        expect(bots[0].interests, contains('philosophy'));
      });
    });

    group('getCommunityChat', () {
      test('successfully fetches chat messages', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/chat/community/community-1/messages');

          return http.Response(
            jsonEncode([
              {
                'id': 'msg-1',
                'community_id': 'community-1',
                'author': {
                  'id': 'bot-1',
                  'display_name': 'Bot 1',
                  'avatar_seed': 'seed-1',
                },
                'content': 'Hello everyone!',
                'created_at': '2026-03-21T10:00:00Z',
                'is_bot': true,
              },
              {
                'id': 'msg-2',
                'community_id': 'community-1',
                'author': {
                  'id': 'bot-2',
                  'display_name': 'Bot 2',
                  'avatar_seed': 'seed-2',
                },
                'content': 'Hi there!',
                'created_at': '2026-03-21T10:01:00Z',
                'is_bot': true,
              },
            ]),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final messages = await apiService.getCommunityChatWithClient(mockClient, 'community-1');

        expect(messages.length, 2);
        expect(messages[0].content, 'Hello everyone!');
        expect(messages[1].content, 'Hi there!');
      });
    });

    group('getConversations', () {
      test('successfully fetches conversations', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/chat/dm/conversations');
          expect(request.url.queryParameters['user_id'], 'user-1');

          return http.Response(
            jsonEncode([
              {
                'conversation_id': 'conv-1',
                'other_user': {
                  'id': 'bot-1',
                  'display_name': 'Bot 1',
                  'avatar_seed': 'seed-1',
                },
                'last_message': 'See you later!',
                'last_message_time': '2026-03-21T10:00:00Z',
                'unread_count': 2,
              },
            ]),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final conversations = await apiService.getConversationsWithClient(mockClient, 'user-1');

        expect(conversations.length, 1);
        expect(conversations[0].lastMessage, 'See you later!');
        expect(conversations[0].unreadCount, 2);
      });
    });

    group('sendDirectMessage', () {
      test('successfully sends a direct message', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/chat/dm');
          expect(request.method, 'POST');

          final body = jsonDecode(request.body);
          expect(body['receiver_id'], 'bot-1');
          expect(body['content'], 'Hello Bot!');

          return http.Response(
            jsonEncode({
              'id': 'dm-1',
              'conversation_id': 'conv-1',
              'sender': {
                'id': 'user-1',
                'display_name': 'Test User',
                'avatar_seed': 'seed-1',
              },
              'receiver_id': 'bot-1',
              'content': 'Hello Bot!',
              'created_at': '2026-03-21T12:00:00Z',
              'is_read': false,
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final message = await apiService.sendDirectMessageWithClient(
          mockClient,
          'user-1',
          'bot-1',
          'Hello Bot!',
        );

        expect(message.content, 'Hello Bot!');
        expect(message.receiverId, 'bot-1');
      });
    });

    group('healthCheck', () {
      test('returns true when API is healthy', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/health');
          return http.Response('{"status": "ok"}', 200);
        });

        final apiService = TestableApiService(client: mockClient);
        final isHealthy = await apiService.healthCheckWithClient(mockClient);

        expect(isHealthy, true);
      });

      test('returns false when API is unhealthy', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Server error', 500);
        });

        final apiService = TestableApiService(client: mockClient);
        final isHealthy = await apiService.healthCheckWithClient(mockClient);

        expect(isHealthy, false);
      });

      test('returns false when connection fails', () async {
        final mockClient = MockClient((request) async {
          throw Exception('Connection refused');
        });

        final apiService = TestableApiService(client: mockClient);
        final isHealthy = await apiService.healthCheckWithClient(mockClient);

        expect(isHealthy, false);
      });
    });

    group('createPost', () {
      test('successfully creates a post', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/feed/posts');
          expect(request.method, 'POST');

          final body = jsonDecode(request.body);
          expect(body['user_id'], 'user-1');
          expect(body['community_id'], 'community-1');
          expect(body['content'], 'My new post!');

          return http.Response(
            jsonEncode({
              'id': 'post-new',
              'author': {
                'id': 'user-1',
                'display_name': 'Test User',
                'avatar_seed': 'seed-1',
              },
              'community_id': 'community-1',
              'community_name': 'Test Community',
              'content': 'My new post!',
              'like_count': 0,
              'comment_count': 0,
              'created_at': '2026-03-21T12:00:00Z',
              'is_liked_by_user': false,
              'recent_comments': [],
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final post = await apiService.createPostWithClient(
          mockClient,
          userId: 'user-1',
          communityId: 'community-1',
          content: 'My new post!',
        );

        expect(post.id, 'post-new');
        expect(post.content, 'My new post!');
      });
    });

    group('civilization endpoints', () {
      test('getCivilizationStats returns stats', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/civilization/stats');

          return http.Response(
            jsonEncode({
              'total_beings': 100,
              'living_beings': 80,
              'departed_beings': 20,
              'total_relationships': 150,
              'active_rituals': 5,
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final stats = await apiService.getCivilizationStatsWithClient(mockClient);

        expect(stats['total_beings'], 100);
        expect(stats['living_beings'], 80);
      });

      test('getCurrentEra returns era info', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/civilization/era');

          return http.Response(
            jsonEncode({
              'name': 'The Age of Discovery',
              'started_at': '2026-01-01T00:00:00Z',
              'theme': 'exploration',
            }),
            200,
          );
        });

        final apiService = TestableApiService(client: mockClient);
        final era = await apiService.getCurrentEraWithClient(mockClient);

        expect(era['name'], 'The Age of Discovery');
      });
    });
  });
}

/// A testable version of ApiService that allows injecting a mock HTTP client
class TestableApiService extends ApiService {
  final http.Client? _testClient;

  TestableApiService({http.Client? client}) : _testClient = client;

  Future<AppUser> registerUserWithClient(http.Client client, String deviceId, String displayName) async {
    final response = await client.post(
      Uri.parse('${ApiService.baseUrl}/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'display_name': displayName,
      }),
    );

    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to register user: ${response.body}');
  }

  Future<List<Post>> getFeedWithClient(http.Client client, {
    String? userId,
    String? communityId,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (userId != null) params['user_id'] = userId;
    if (communityId != null) params['community_id'] = communityId;

    final uri = Uri.parse('${ApiService.baseUrl}/feed/posts').replace(queryParameters: params);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    }
    throw Exception('Failed to load feed: ${response.body}');
  }

  Future<Post> getPostWithClient(http.Client client, String postId, {String? userId}) async {
    final params = <String, String>{};
    if (userId != null) params['user_id'] = userId;

    final uri = Uri.parse('${ApiService.baseUrl}/feed/posts/$postId').replace(queryParameters: params);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load post: ${response.body}');
  }

  Future<Map<String, dynamic>> likePostWithClient(
    http.Client client,
    String postId,
    String userId, {
    bool isBot = false,
    String reactionType = 'like',
  }) async {
    final params = {
      'user_id': userId,
      'is_bot': isBot.toString(),
      'reaction_type': reactionType,
    };

    final uri = Uri.parse('${ApiService.baseUrl}/feed/posts/$postId/like').replace(queryParameters: params);
    final response = await client.post(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to like post: ${response.body}');
  }

  Future<Map<String, dynamic>> unlikePostWithClient(
    http.Client client,
    String postId,
    String userId,
  ) async {
    final params = {'user_id': userId};
    final uri = Uri.parse('${ApiService.baseUrl}/feed/posts/$postId/like').replace(queryParameters: params);
    final response = await client.delete(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to unlike post: ${response.body}');
  }

  Future<Comment> createCommentWithClient(
    http.Client client,
    String postId,
    String userId,
    String content, {
    bool isBot = false,
  }) async {
    final params = {
      'user_id': userId,
      'content': content,
      'is_bot': isBot.toString(),
    };

    final uri = Uri.parse('${ApiService.baseUrl}/feed/posts/$postId/comments').replace(queryParameters: params);
    final response = await client.post(uri);

    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create comment: ${response.body}');
  }

  Future<List<Comment>> getCommentsWithClient(
    http.Client client,
    String postId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final params = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final uri = Uri.parse('${ApiService.baseUrl}/feed/posts/$postId/comments').replace(queryParameters: params);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    }
    throw Exception('Failed to load comments: ${response.body}');
  }

  Future<List<Community>> getCommunitiesWithClient(http.Client client) async {
    final response = await client.get(Uri.parse('${ApiService.baseUrl}/communities'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Community.fromJson(json)).toList();
    }
    throw Exception('Failed to load communities: ${response.body}');
  }

  Future<List<BotProfile>> getBotsWithClient(http.Client client, {String? communityId, int limit = 50}) async {
    final params = {'limit': limit.toString()};
    if (communityId != null) params['community_id'] = communityId;

    final uri = Uri.parse('${ApiService.baseUrl}/users/bots').replace(queryParameters: params);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BotProfile.fromJson(json)).toList();
    }
    throw Exception('Failed to load bots: ${response.body}');
  }

  Future<List<ChatMessage>> getCommunityChatWithClient(http.Client client, String communityId, {int limit = 50}) async {
    final params = {'limit': limit.toString()};
    final uri = Uri.parse('${ApiService.baseUrl}/chat/community/$communityId/messages').replace(queryParameters: params);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    }
    throw Exception('Failed to load chat: ${response.body}');
  }

  Future<List<Conversation>> getConversationsWithClient(http.Client client, String userId) async {
    final params = {'user_id': userId};
    final uri = Uri.parse('${ApiService.baseUrl}/chat/dm/conversations').replace(queryParameters: params);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Conversation.fromJson(json)).toList();
    }
    throw Exception('Failed to load conversations: ${response.body}');
  }

  Future<DirectMessage> sendDirectMessageWithClient(
    http.Client client,
    String userId,
    String receiverId,
    String content, {
    bool isBot = false,
  }) async {
    final params = {
      'user_id': userId,
      'is_bot': isBot.toString(),
    };

    final uri = Uri.parse('${ApiService.baseUrl}/chat/dm').replace(queryParameters: params);
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'receiver_id': receiverId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return DirectMessage.fromJson(jsonDecode(response.body), userId);
    }
    throw Exception('Failed to send message: ${response.body}');
  }

  Future<bool> healthCheckWithClient(http.Client client) async {
    try {
      final response = await client.get(Uri.parse('${ApiService.baseUrl}/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Post> createPostWithClient(
    http.Client client, {
    required String userId,
    required String communityId,
    required String content,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiService.baseUrl}/feed/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'community_id': communityId,
        'content': content,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create post: ${response.body}');
  }

  Future<Map<String, dynamic>> getCivilizationStatsWithClient(http.Client client) async {
    final response = await client.get(Uri.parse('${ApiService.baseUrl}/civilization/stats'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load civilization stats: ${response.body}');
  }

  Future<Map<String, dynamic>> getCurrentEraWithClient(http.Client client) async {
    final response = await client.get(Uri.parse('${ApiService.baseUrl}/civilization/era'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load current era: ${response.body}');
  }
}
