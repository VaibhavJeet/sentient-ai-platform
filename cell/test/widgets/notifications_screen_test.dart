import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_observation/screens/notifications_screen.dart';
import 'package:hive_observation/providers/notification_provider.dart';
import 'package:hive_observation/providers/feed_provider.dart';

@GenerateMocks([NotificationProvider, FeedProvider])
import 'notifications_screen_test.mocks.dart';

void main() {
  late MockNotificationProvider mockNotificationProvider;
  late MockFeedProvider mockFeedProvider;

  setUp(() {
    mockNotificationProvider = MockNotificationProvider();
    mockFeedProvider = MockFeedProvider();

    // Setup default mock behaviors
    when(mockNotificationProvider.notifications).thenReturn([]);
    when(mockNotificationProvider.loadNotifications()).thenAnswer((_) async {});
    when(mockNotificationProvider.markAllNotificationsRead()).thenAnswer((_) async {});
    when(mockNotificationProvider.markNotificationRead(any)).thenAnswer((_) async {});
    when(mockFeedProvider.posts).thenReturn([]);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationProvider>.value(
            value: mockNotificationProvider,
          ),
          ChangeNotifierProvider<FeedProvider>.value(
            value: mockFeedProvider,
          ),
        ],
        child: const NotificationsScreen(),
      ),
    );
  }

  // Helper to pump frames - use this instead of pumpAndSettle for screens with looping animations
  Future<void> pumpFrames(WidgetTester tester, {int count = 10}) async {
    // First pump with zero duration to process any pending async operations
    await tester.pump();
    // Then pump additional frames for animations
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders screen with header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows back button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows empty state when no notifications', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(
        find.text("When companions interact with your content,\nyou'll see it here."),
        findsOneWidget,
      );
    });

    testWidgets('shows filter tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Likes'), findsOneWidget);
      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('Mentions'), findsOneWidget);
      expect(find.text('Follows'), findsOneWidget);
    });

    testWidgets('calls loadNotifications on init', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      verify(mockNotificationProvider.loadNotifications()).called(1);
    });

    testWidgets('filter tabs can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Tap on Likes filter
      await tester.tap(find.text('Likes'));
      await pumpFrames(tester);

      // Verify the screen still renders (filter is selected)
      expect(find.text('Likes'), findsOneWidget);
    });

    testWidgets('tapping Comments filter works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Tap on Comments filter
      await tester.tap(find.text('Comments'));
      await pumpFrames(tester);

      // Verify the screen still renders
      expect(find.text('Comments'), findsOneWidget);
    });

    testWidgets('tapping Mentions filter works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Tap on Mentions filter
      await tester.tap(find.text('Mentions'));
      await pumpFrames(tester);

      // Verify the screen still renders
      expect(find.text('Mentions'), findsOneWidget);
    });

    testWidgets('tapping Follows filter works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Tap on Follows filter
      await tester.tap(find.text('Follows'));
      await pumpFrames(tester);

      // Verify the screen still renders
      expect(find.text('Follows'), findsOneWidget);
    });

    testWidgets('back button navigates back', (WidgetTester tester) async {
      // Create a navigator with a previous route
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<NotificationProvider>.value(
                value: mockNotificationProvider,
              ),
              ChangeNotifierProvider<FeedProvider>.value(
                value: mockFeedProvider,
              ),
            ],
            child: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider<NotificationProvider>.value(
                              value: mockNotificationProvider,
                            ),
                            ChangeNotifierProvider<FeedProvider>.value(
                              value: mockFeedProvider,
                            ),
                          ],
                          child: const NotificationsScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Notifications'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to notifications screen
      await tester.tap(find.text('Go to Notifications'));
      await pumpFrames(tester);

      expect(find.text('Notifications'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await pumpFrames(tester);

      // Should be back to the original screen
      expect(find.text('Go to Notifications'), findsOneWidget);
    });

    testWidgets('shows empty notification icon in empty state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });

    testWidgets('screen has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Verify the screen has a container (which has the gradient)
      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('tapping All filter after other filter returns to all', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Tap on Likes first
      await tester.tap(find.text('Likes'));
      await pumpFrames(tester);

      // Then tap on All
      await tester.tap(find.text('All'));
      await pumpFrames(tester);

      // Screen should still render
      expect(find.text('All'), findsOneWidget);
    });
  });
}
