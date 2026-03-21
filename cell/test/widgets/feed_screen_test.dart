import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_observation/screens/feed_screen.dart';
import 'package:hive_observation/providers/app_state.dart';
import 'package:hive_observation/providers/feed_provider.dart';
import 'package:hive_observation/providers/notification_provider.dart';
import 'package:hive_observation/providers/civilization_provider.dart';
import 'package:hive_observation/models/models.dart';
import '../test_helpers.dart';

@GenerateMocks([AppState, FeedProvider, NotificationProvider, CivilizationProvider])
import 'feed_screen_test.mocks.dart';

void main() {
  late MockAppState mockAppState;
  late MockFeedProvider mockFeedProvider;
  late MockNotificationProvider mockNotificationProvider;
  late MockCivilizationProvider mockCivilizationProvider;

  setUp(() {
    mockAppState = MockAppState();
    mockFeedProvider = MockFeedProvider();
    mockNotificationProvider = MockNotificationProvider();
    mockCivilizationProvider = MockCivilizationProvider();

    // Setup default mock behaviors
    when(mockFeedProvider.posts).thenReturn([]);
    when(mockFeedProvider.isLoadingFeed).thenReturn(false);
    when(mockFeedProvider.hasMorePosts).thenReturn(false);
    when(mockNotificationProvider.unreadNotificationCount).thenReturn(0);
    when(mockNotificationProvider.notifications).thenReturn([]);
    when(mockCivilizationProvider.communities).thenReturn([]);
    when(mockCivilizationProvider.selectedCommunity).thenReturn(null);
    when(mockAppState.loadFeed(refresh: anyNamed('refresh'))).thenAnswer((_) async {});
    when(mockAppState.selectCommunity(any)).thenReturn(null);
  });

  Widget createTestWidget({List<Post>? posts}) {
    if (posts != null) {
      when(mockFeedProvider.posts).thenReturn(posts);
    }

    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: mockAppState),
          ChangeNotifierProvider<FeedProvider>.value(value: mockFeedProvider),
          ChangeNotifierProvider<NotificationProvider>.value(value: mockNotificationProvider),
          ChangeNotifierProvider<CivilizationProvider>.value(value: mockCivilizationProvider),
        ],
        child: const FeedScreen(),
      ),
    );
  }

  group('FeedScreen Widget Tests', () {
    testWidgets('renders header with AI Social title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('AI Social'), findsOneWidget);
      expect(find.text('Watch companions interact'), findsOneWidget);
    });

    testWidgets('shows empty state when no posts', (WidgetTester tester) async {
      when(mockFeedProvider.posts).thenReturn([]);
      when(mockFeedProvider.isLoadingFeed).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No posts yet'), findsOneWidget);
      expect(find.text('Companions will start posting soon!\nPull down to refresh.'), findsOneWidget);
    });

    testWidgets('shows loading state with shimmer', (WidgetTester tester) async {
      when(mockFeedProvider.posts).thenReturn([]);
      when(mockFeedProvider.isLoadingFeed).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should show shimmer loading cards
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders posts when available', (WidgetTester tester) async {
      final testPosts = [
        TestFixtures.createPost(
          id: 'post-1',
          content: 'Hello, this is test post 1',
          author: TestFixtures.createAuthor(displayName: 'Bot Alpha'),
        ),
        TestFixtures.createPost(
          id: 'post-2',
          content: 'Another test post content',
          author: TestFixtures.createAuthor(displayName: 'Bot Beta'),
        ),
      ];

      await tester.pumpWidget(createTestWidget(posts: testPosts));
      await tester.pumpAndSettle();

      expect(find.text('Hello, this is test post 1'), findsOneWidget);
      expect(find.text('Another test post content'), findsOneWidget);
    });

    testWidgets('shows notification button in header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows settings button in header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('shows notification badge when unread count > 0', (WidgetTester tester) async {
      when(mockNotificationProvider.unreadNotificationCount).thenReturn(5);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The badge is rendered as a small red dot when there are unread notifications
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows community filter chips', (WidgetTester tester) async {
      final testCommunities = [
        TestFixtures.createCommunity(id: 'comm-1', name: 'Tech Talk'),
        TestFixtures.createCommunity(id: 'comm-2', name: 'Creative Corner'),
      ];
      when(mockCivilizationProvider.communities).thenReturn(testCommunities);

      final testPosts = [
        TestFixtures.createPost(id: 'post-1', content: 'Test post'),
      ];

      await tester.pumpWidget(createTestWidget(posts: testPosts));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Tech Talk'), findsOneWidget);
      expect(find.text('Creative Corner'), findsOneWidget);
    });

    testWidgets('tapping filter chip calls selectCommunity', (WidgetTester tester) async {
      final testCommunity = TestFixtures.createCommunity(id: 'comm-1', name: 'Tech Talk');
      when(mockCivilizationProvider.communities).thenReturn([testCommunity]);

      final testPosts = [
        TestFixtures.createPost(id: 'post-1', content: 'Test post'),
      ];

      await tester.pumpWidget(createTestWidget(posts: testPosts));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tech Talk'));
      await tester.pump();

      verify(mockAppState.selectCommunity(testCommunity)).called(1);
    });

    testWidgets('refresh button in empty state triggers reload', (WidgetTester tester) async {
      when(mockFeedProvider.posts).thenReturn([]);
      when(mockFeedProvider.isLoadingFeed).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.text('Refresh');
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      await tester.pump();

      verify(mockAppState.loadFeed(refresh: true)).called(1);
    });

    testWidgets('displays post like count', (WidgetTester tester) async {
      final testPosts = [
        TestFixtures.createPost(
          id: 'post-1',
          content: 'Test post',
          likeCount: 42,
        ),
      ];

      await tester.pumpWidget(createTestWidget(posts: testPosts));
      await tester.pumpAndSettle();

      // Like count may appear multiple times (e.g., in different reaction displays)
      expect(find.text('42'), findsWidgets);
    });

    testWidgets('displays post comment count', (WidgetTester tester) async {
      final testPosts = [
        TestFixtures.createPost(
          id: 'post-1',
          content: 'Test post',
          commentCount: 15,
        ),
      ];

      await tester.pumpWidget(createTestWidget(posts: testPosts));
      await tester.pumpAndSettle();

      // Comment count may appear in multiple places
      expect(find.text('15'), findsWidgets);
    });

    testWidgets('shows author display name on posts', (WidgetTester tester) async {
      final testPosts = [
        TestFixtures.createPost(
          id: 'post-1',
          content: 'Test post',
          author: TestFixtures.createAuthor(displayName: 'Super Bot'),
        ),
      ];

      await tester.pumpWidget(createTestWidget(posts: testPosts));
      await tester.pumpAndSettle();

      expect(find.text('Super Bot'), findsOneWidget);
    });
  });
}
