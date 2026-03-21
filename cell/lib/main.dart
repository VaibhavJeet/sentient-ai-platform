import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'providers/app_state.dart';
import 'providers/feed_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/notification_preferences_provider.dart';
import 'providers/civilization_provider.dart';
import 'providers/settings_provider.dart';
import 'config/config.dart';
import 'services/error_service.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/error_boundary.dart';

void main() {
  // Run the app with error handling
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize environment configuration
      // Override these values for different environments or custom API URLs
      // For physical device testing, pass your machine's IP:
      //   EnvConfig.initialize(apiUrl: 'http://192.168.1.100:8000');
      EnvConfig.initialize();

      // Initialize Firebase for push notifications (mobile only)
      if (!kIsWeb) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          debugPrint('Firebase initialized successfully');
        } catch (e) {
          debugPrint('Firebase initialization failed: $e');
          // Continue without Firebase - push notifications won't work
        }
      }

      // Set up Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        ErrorService.instance.handleFlutterError(details);
        // In debug mode, also print to console using default handler
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(details);
        }
      };

      // Handle errors in the presentation layer (widget errors)
      ErrorWidget.builder = (FlutterErrorDetails details) {
        ErrorService.instance.handleFlutterError(details);
        return ErrorFallbackWidget(error: details);
      };

      // Set preferred orientations
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.surfaceColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ));

      // Configure timeago locale
      timeago.setLocaleMessages('en_short', timeago.EnShortMessages());

      runApp(const HiveApp());
    },
    (error, stackTrace) {
      // Handle errors that escape the Flutter framework
      ErrorService.instance.handleAsyncError(error, stackTrace);
    },
  );
}

class HiveApp extends StatelessWidget {
  const HiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationPreferencesProvider()),
        // Expose feature providers from AppState for direct access
        ChangeNotifierProxyProvider<AppState, FeedProvider>(
          create: (_) => FeedProvider(),
          update: (_, appState, previous) => appState.feedProvider,
        ),
        ChangeNotifierProxyProvider<AppState, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, appState, previous) => appState.chatProvider,
        ),
        ChangeNotifierProxyProvider<AppState, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, appState, previous) => appState.notificationProvider,
        ),
        ChangeNotifierProxyProvider<AppState, CivilizationProvider>(
          create: (_) => CivilizationProvider(),
          update: (_, appState, previous) => appState.civilizationProvider,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Hive',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.darkTheme, // Light theme can be added later
            darkTheme: AppTheme.darkTheme,
            builder: (context, child) {
              // Wrap the entire app with error boundary
              return ErrorBoundary(
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _statusText = 'Connecting...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Get providers before async operations
    final settings = context.read<SettingsProvider>();
    final notificationPrefs = context.read<NotificationPreferencesProvider>();
    final appState = context.read<AppState>();

    await Future.delayed(const Duration(milliseconds: 500));

    // Load settings first
    await settings.loadSettings();

    // Load notification preferences
    await notificationPrefs.loadPreferences();

    setState(() => _statusText = 'Initializing...');
    await Future.delayed(const Duration(milliseconds: 300));

    await appState.initialize();

    // Initialize push notifications (non-blocking)
    if (!kIsWeb) {
      _initializePushNotifications();
    }

    if (appState.error != null) {
      setState(() {
        _statusText = appState.error!;
        _hasError = true;
      });
      return;
    }

    setState(() => _statusText = 'Loading communities...');
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() => _statusText = 'Ready!');
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Check if onboarding is complete
      if (!settings.onboardingComplete) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OnboardingScreen(
              onComplete: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _statusText = 'Connecting...';
    });
    _initialize();
  }

  /// Initialize push notifications in the background
  Future<void> _initializePushNotifications() async {
    try {
      final pushService = PushNotificationService.instance;
      await pushService.initialize();

      // Listen for notification events
      pushService.onNotificationReceived.listen((event) {
        debugPrint('Received civilization event: ${event.title}');
        // The event can be used to navigate to specific screens
        // or show in-app notifications
      });

      debugPrint('Push notifications initialized');
    } catch (e) {
      debugPrint('Failed to initialize push notifications: $e');
      // Non-fatal - app continues without push notifications
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Hive',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A Digital Civilization',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Status
                if (!_hasError) ...[
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _statusText,
                  style: TextStyle(
                    color: _hasError ? AppTheme.errorColor : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_hasError) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Make sure the API server is running:\n'
                      'python -m mind.api.main',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
