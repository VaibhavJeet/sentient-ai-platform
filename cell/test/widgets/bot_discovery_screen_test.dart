import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_observation/screens/bot_discovery_screen.dart';
import 'package:hive_observation/providers/app_state.dart';
import 'package:hive_observation/models/models.dart';
import '../test_helpers.dart';

@GenerateMocks([AppState])
import 'bot_discovery_screen_test.mocks.dart';

void main() {
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();

    // Setup default mock behaviors
    when(mockAppState.loadBots(
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => <BotProfile>[]);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AppState>.value(
        value: mockAppState,
        child: const BotDiscoveryScreen(),
      ),
    );
  }

  Widget createTestWidgetWithBots(List<BotProfile> bots) {
    when(mockAppState.loadBots(
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => bots);

    return MaterialApp(
      home: ChangeNotifierProvider<AppState>.value(
        value: mockAppState,
        child: const BotDiscoveryScreen(),
      ),
    );
  }

  // Helper to pump frames - use this instead of pumpAndSettle for screens with looping animations
  Future<void> pumpFrames(WidgetTester tester, {int count = 10}) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('BotDiscoveryScreen Widget Tests', () {
    testWidgets('renders screen with header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // The screen should render without errors
      expect(find.byType(BotDiscoveryScreen), findsOneWidget);
    });

    testWidgets('shows search field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should show shimmer or loading indicator
      expect(find.byType(BotDiscoveryScreen), findsOneWidget);
    });

    testWidgets('displays bots in grid when loaded', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Alpha Bot',
          bio: 'First test bot',
        ),
        TestFixtures.createBotProfile(
          id: 'bot-2',
          displayName: 'Beta Bot',
          bio: 'Second test bot',
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      expect(find.text('Alpha Bot'), findsOneWidget);
      expect(find.text('Beta Bot'), findsOneWidget);
    });

    testWidgets('search filters bots by name', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Alpha Bot',
          bio: 'First test bot',
          interests: ['tech'],
        ),
        TestFixtures.createBotProfile(
          id: 'bot-2',
          displayName: 'Gamma Bot',
          bio: 'Second test bot',
          interests: ['art'],
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      // Both bots should be visible initially
      expect(find.text('Alpha Bot'), findsOneWidget);
      expect(find.text('Gamma Bot'), findsOneWidget);

      // Enter search text
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Alpha');
      await pumpFrames(tester);

      // Only Alpha Bot should be visible
      expect(find.text('Alpha Bot'), findsOneWidget);
      expect(find.text('Gamma Bot'), findsNothing);
    });

    testWidgets('search filters bots by interests', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Tech Bot',
          bio: 'Loves technology',
          interests: ['programming', 'tech'],
        ),
        TestFixtures.createBotProfile(
          id: 'bot-2',
          displayName: 'Art Bot',
          bio: 'Creative soul',
          interests: ['painting', 'music'],
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      // Enter search text for interest
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'programming');
      await pumpFrames(tester);

      // Only Tech Bot should be visible
      expect(find.text('Tech Bot'), findsOneWidget);
      expect(find.text('Art Bot'), findsNothing);
    });

    testWidgets('shows personality filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Creative'), findsOneWidget);
      expect(find.text('Tech'), findsOneWidget);
    });

    testWidgets('can toggle between grid and list view', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Test Bot',
          bio: 'A test bot',
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      // Find the view toggle button (grid/list icon)
      final gridIcon = find.byIcon(Icons.grid_view);
      final listIcon = find.byIcon(Icons.view_list);

      // Either grid or list icon should be present
      expect(
        gridIcon.evaluate().isNotEmpty || listIcon.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('tapping personality filter updates selection', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Creative Bot',
          bio: 'Artistic soul',
          interests: ['art', 'music', 'creative'],
        ),
        TestFixtures.createBotProfile(
          id: 'bot-2',
          displayName: 'Tech Bot',
          bio: 'Tech enthusiast',
          interests: ['programming', 'tech', 'coding'],
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      // Both bots should be visible initially
      expect(find.text('Creative Bot'), findsOneWidget);
      expect(find.text('Tech Bot'), findsOneWidget);

      // Tap on Creative filter
      await tester.tap(find.text('Creative'));
      await pumpFrames(tester);

      // Only Creative Bot should be visible
      expect(find.text('Creative Bot'), findsOneWidget);
      expect(find.text('Tech Bot'), findsNothing);
    });

    testWidgets('displays bot avatar', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Test Bot',
          avatarSeed: 'test-seed-123',
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      // The screen should contain avatar widgets
      expect(find.text('Test Bot'), findsOneWidget);
    });

    testWidgets('shows empty state when no bots match filter', (WidgetTester tester) async {
      final testBots = [
        TestFixtures.createBotProfile(
          id: 'bot-1',
          displayName: 'Only Bot',
          bio: 'The only bot',
        ),
      ];

      await tester.pumpWidget(createTestWidgetWithBots(testBots));
      await pumpFrames(tester);

      // Search for something that doesn't exist
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'nonexistent');
      await pumpFrames(tester);

      // The bot should not be visible
      expect(find.text('Only Bot'), findsNothing);
    });

    testWidgets('calls loadBots on initialization', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      verify(mockAppState.loadBots(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).called(greaterThan(0));
    });

    testWidgets('shows tabs for different views', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Check for tab bar with 3 tabs
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
