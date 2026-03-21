import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

import 'environment.dart';

/// Helper class to load and parse environment configuration
///
/// This class handles platform-specific URL detection and provides
/// convenient access to configuration values.
class EnvConfig {
  /// Initialize environment from runtime configuration
  ///
  /// [envString] - Environment name ('dev', 'staging', 'prod')
  /// [apiUrl] - Optional override for API URL
  /// [wsUrl] - Optional override for WebSocket URL
  static void initialize({
    String? envString,
    String? apiUrl,
    String? wsUrl,
  }) {
    final environment = _parseEnvironment(envString);

    // Apply platform-specific URL transformations for dev environment
    String? effectiveApiUrl = apiUrl;
    String? effectiveWsUrl = wsUrl;

    if (environment == Environment.dev && apiUrl == null) {
      effectiveApiUrl = _getPlatformApiUrl();
    }

    if (environment == Environment.dev && wsUrl == null) {
      effectiveWsUrl = _getPlatformWsUrl();
    }

    EnvironmentConfig.init(
      environment: environment,
      overrideApiUrl: effectiveApiUrl,
      overrideWsUrl: effectiveWsUrl,
    );
  }

  /// Parse environment string to enum
  static Environment _parseEnvironment(String? envString) {
    if (envString == null) {
      // Default to dev in debug mode, prod in release mode
      return kReleaseMode ? Environment.prod : Environment.dev;
    }

    switch (envString.toLowerCase()) {
      case 'dev':
      case 'development':
        return Environment.dev;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'prod':
      case 'production':
        return Environment.prod;
      default:
        return Environment.dev;
    }
  }

  /// Get platform-appropriate API URL for development
  ///
  /// Android emulator uses 10.0.2.2 to access host localhost
  /// iOS simulator and web use localhost directly
  static String _getPlatformApiUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      // Android emulator uses 10.0.2.2 to access host localhost
      // For iOS simulator, localhost works directly
      // For physical devices, you'll need to override with actual IP
      return 'http://10.0.2.2:8000';
    }
  }

  /// Get platform-appropriate WebSocket URL for development
  static String _getPlatformWsUrl() {
    if (kIsWeb) {
      return 'ws://localhost:8000/ws';
    } else {
      return 'ws://10.0.2.2:8000/ws';
    }
  }

  /// Quick access to API base URL
  static String get apiBaseUrl => EnvironmentConfig.instance.apiBaseUrl;

  /// Quick access to WebSocket base URL
  static String get wsBaseUrl => EnvironmentConfig.instance.wsBaseUrl;

  /// Quick access to current environment
  static Environment get environment => EnvironmentConfig.instance.environment;

  /// Whether logging is enabled
  static bool get enableLogging => EnvironmentConfig.instance.enableLogging;

  /// Connection timeout in milliseconds
  static int get connectionTimeout => EnvironmentConfig.instance.connectionTimeout;

  /// Convenience getters
  static bool get isDev => EnvironmentConfig.instance.isDev;
  static bool get isStaging => EnvironmentConfig.instance.isStaging;
  static bool get isProd => EnvironmentConfig.instance.isProd;
}
