/// Environment types supported by the app
enum Environment {
  dev,
  staging,
  prod,
}

/// Environment configuration for the app
///
/// This class holds all environment-specific configuration values.
/// Use [EnvironmentConfig.init] to initialize before the app starts.
class EnvironmentConfig {
  /// Current environment
  final Environment environment;

  /// Base URL for REST API calls
  final String apiBaseUrl;

  /// WebSocket URL for real-time connections
  final String wsBaseUrl;

  /// Whether to enable debug logging
  final bool enableLogging;

  /// Connection timeout in milliseconds
  final int connectionTimeout;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    this.enableLogging = false,
    this.connectionTimeout = 30000,
  });

  /// Singleton instance
  static EnvironmentConfig? _instance;

  /// Get the current configuration instance
  /// Throws if [init] hasn't been called
  static EnvironmentConfig get instance {
    if (_instance == null) {
      throw StateError(
        'EnvironmentConfig not initialized. Call EnvironmentConfig.init() first.',
      );
    }
    return _instance!;
  }

  /// Check if configuration is initialized
  static bool get isInitialized => _instance != null;

  /// Initialize the environment configuration
  ///
  /// This should be called once at app startup, before any API calls.
  ///
  /// [environment] - The target environment
  /// [overrideApiUrl] - Optional custom API URL (useful for local dev)
  /// [overrideWsUrl] - Optional custom WebSocket URL
  static void init({
    required Environment environment,
    String? overrideApiUrl,
    String? overrideWsUrl,
  }) {
    final config = _getConfigForEnvironment(environment);

    _instance = EnvironmentConfig(
      environment: environment,
      apiBaseUrl: overrideApiUrl ?? config.apiBaseUrl,
      wsBaseUrl: overrideWsUrl ?? config.wsBaseUrl,
      enableLogging: config.enableLogging,
      connectionTimeout: config.connectionTimeout,
    );
  }

  /// Get configuration for a specific environment
  static EnvironmentConfig _getConfigForEnvironment(Environment env) {
    switch (env) {
      case Environment.dev:
        return const EnvironmentConfig(
          environment: Environment.dev,
          apiBaseUrl: 'http://localhost:8000',
          wsBaseUrl: 'ws://localhost:8000/ws',
          enableLogging: true,
          connectionTimeout: 30000,
        );
      case Environment.staging:
        return const EnvironmentConfig(
          environment: Environment.staging,
          apiBaseUrl: 'https://staging-api.sentient.app',
          wsBaseUrl: 'wss://staging-api.sentient.app/ws',
          enableLogging: true,
          connectionTimeout: 30000,
        );
      case Environment.prod:
        return const EnvironmentConfig(
          environment: Environment.prod,
          apiBaseUrl: 'https://api.sentient.app',
          wsBaseUrl: 'wss://api.sentient.app/ws',
          enableLogging: false,
          connectionTimeout: 60000,
        );
    }
  }

  /// Reset configuration (useful for testing)
  static void reset() {
    _instance = null;
  }

  /// Whether this is a development environment
  bool get isDev => environment == Environment.dev;

  /// Whether this is a staging environment
  bool get isStaging => environment == Environment.staging;

  /// Whether this is a production environment
  bool get isProd => environment == Environment.prod;

  @override
  String toString() {
    return 'EnvironmentConfig('
        'environment: $environment, '
        'apiBaseUrl: $apiBaseUrl, '
        'wsBaseUrl: $wsBaseUrl, '
        'enableLogging: $enableLogging, '
        'connectionTimeout: $connectionTimeout'
        ')';
  }
}
