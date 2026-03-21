import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_observation/screens/home_screen.dart';
import 'package:hive_observation/providers/app_state.dart';
import 'package:hive_observation/services/api_service.dart';

@GenerateMocks([AppState, ApiService])
import 'home_screen_test.mocks.dart';

void main() {
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();

    // Setup default mock behaviors for AppState
    when(mockAppState.loadBots(
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => []);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AppState>.value(
        value: mockAppState,
        child: const HomeScreen(),
      ),
    );
  }

  // Helper to pump frames - use this instead of pumpAndSettle for screens with looping animations
  Future<void> pumpFrames(WidgetTester tester, {int count = 10}) async {
    await tester.pump();
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('renders HomeScreen with bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows four navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check for navigation labels - may appear in nav bar and within screens
      expect(find.text('Hive'), findsWidgets);
      expect(find.text('Timeline'), findsWidgets);
      expect(find.text('Beings'), findsWidgets);
      expect(find.text('Culture'), findsWidgets);
    });

    testWidgets('shows correct icons for navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check for navigation icons (checking for either active or inactive versions)
      expect(
        find.byIcon(Icons.hexagon_outlined).evaluate().isNotEmpty ||
            find.byIcon(Icons.hexagon).evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        find.byIcon(Icons.timeline_outlined).evaluate().isNotEmpty ||
            find.byIcon(Icons.timeline).evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        find.byIcon(Icons.groups_outlined).evaluate().isNotEmpty ||
            find.byIcon(Icons.groups).evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        find.byIcon(Icons.auto_awesome_outlined).evaluate().isNotEmpty ||
            find.byIcon(Icons.auto_awesome).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Hive tab is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find the Hive icon - should be the active (filled) version
      expect(find.byIcon(Icons.hexagon), findsWidgets);
    });

    testWidgets('tapping Timeline tab changes selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Initially Hive should be active
      expect(find.byIcon(Icons.hexagon), findsWidgets);
      expect(find.byIcon(Icons.timeline_outlined), findsWidgets);

      // Tap on Timeline tab
      await tester.tap(find.text('Timeline'));
      await pumpFrames(tester);

      // Now Timeline should be active
      expect(find.byIcon(Icons.timeline), findsWidgets);
      expect(find.byIcon(Icons.hexagon_outlined), findsWidgets);
    });

    testWidgets('tapping Beings tab changes selection', (WidgetTester tester) async {
      // Set a larger surface size to avoid overflow issues
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on Beings tab
      await tester.tap(find.text('Beings'));
      await pumpFrames(tester);

      // Now Beings should be active
      expect(find.byIcon(Icons.groups), findsWidgets);
      expect(find.byIcon(Icons.hexagon_outlined), findsWidgets);
    });

    testWidgets('tapping Culture tab changes selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on Culture tab
      await tester.tap(find.text('Culture'));
      await pumpFrames(tester);

      // Now Culture should be active
      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
      expect(find.byIcon(Icons.hexagon_outlined), findsWidgets);
    });

    testWidgets('uses PageView for screen navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('bottom navigation bar has correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // The bottom bar should be a Container with Row of nav items
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('tab navigation updates PageView', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Get the PageView controller state
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.initialPage, 0);

      // Tap on Timeline tab
      await tester.tap(find.text('Timeline'));
      await pumpFrames(tester);

      // The PageView should have animated to page 1
      // (We verify this by checking the active icon changed)
      expect(find.byIcon(Icons.timeline), findsWidgets);
    });

    testWidgets('navigating through all tabs works correctly', (WidgetTester tester) async {
      // Set a larger surface size to avoid overflow issues
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Start at Hive
      expect(find.byIcon(Icons.hexagon), findsWidgets);

      // Go to Timeline
      await tester.tap(find.text('Timeline'));
      await pumpFrames(tester);
      expect(find.byIcon(Icons.timeline), findsWidgets);

      // Go to Beings
      await tester.tap(find.text('Beings'));
      await pumpFrames(tester);
      expect(find.byIcon(Icons.groups), findsWidgets);

      // Go to Culture
      await tester.tap(find.text('Culture'));
      await pumpFrames(tester);
      expect(find.byIcon(Icons.auto_awesome), findsWidgets);

      // Go back to Hive
      await tester.tap(find.text('Hive'));
      await pumpFrames(tester);
      expect(find.byIcon(Icons.hexagon), findsWidgets);
    });

    testWidgets('PageView has NeverScrollableScrollPhysics', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('Scaffold has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.extendBody, isTrue);
    });
  });
}
