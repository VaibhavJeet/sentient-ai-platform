import 'dart:async';
import 'package:flutter/foundation.dart';

/// Error severity levels for logging and display
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

/// Represents an app error with context
class AppError {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? context;

  AppError({
    required this.message,
    this.error,
    this.stackTrace,
    this.severity = ErrorSeverity.error,
    this.context,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('[$severity] $message');
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    if (error != null) {
      buffer.writeln('Error: $error');
    }
    if (stackTrace != null) {
      buffer.writeln('Stack trace:');
      buffer.writeln(stackTrace);
    }
    return buffer.toString();
  }
}

/// Global error handling service for crash logging and error management
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  static ErrorService get instance => _instance;

  ErrorService._internal();

  /// Stream controller for broadcasting errors to listeners
  final _errorController = StreamController<AppError>.broadcast();

  /// Stream of errors for UI components to listen to
  Stream<AppError> get errorStream => _errorController.stream;

  /// Recent errors buffer for debugging
  final List<AppError> _recentErrors = [];
  static const int _maxRecentErrors = 50;

  /// Get recent errors for debugging
  List<AppError> get recentErrors => List.unmodifiable(_recentErrors);

  /// Log an error with optional context
  void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.error,
    String? context,
  }) {
    final appError = AppError(
      message: message,
      error: error,
      stackTrace: stackTrace,
      severity: severity,
      context: context,
    );

    _addToRecentErrors(appError);
    _printError(appError);
    _errorController.add(appError);
  }

  /// Log a critical/fatal error
  void logCritical(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    logError(
      message,
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.critical,
      context: context,
    );
  }

  /// Log a warning
  void logWarning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  }) {
    logError(
      message,
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.warning,
      context: context,
    );
  }

  /// Log info-level message
  void logInfo(String message, {String? context}) {
    logError(
      message,
      severity: ErrorSeverity.info,
      context: context,
    );
  }

  /// Handle Flutter framework errors
  void handleFlutterError(FlutterErrorDetails details) {
    logCritical(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
      context: details.context?.toString(),
    );
  }

  /// Handle async errors (Zone errors)
  void handleAsyncError(Object error, StackTrace stackTrace) {
    logCritical(
      'Unhandled async error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Get a user-friendly error message
  String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred';
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable')) {
      return 'Unable to connect. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'The request timed out. Please try again.';
    }

    if (errorString.contains('offline')) {
      return 'You appear to be offline. Some features may be unavailable.';
    }

    // Server errors
    if (errorString.contains('500') || errorString.contains('internal server')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication required. Please sign in again.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  void _addToRecentErrors(AppError error) {
    _recentErrors.add(error);
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeAt(0);
    }
  }

  void _printError(AppError error) {
    final severityIcon = switch (error.severity) {
      ErrorSeverity.info => 'INFO',
      ErrorSeverity.warning => 'WARN',
      ErrorSeverity.error => 'ERROR',
      ErrorSeverity.critical => 'CRITICAL',
    };

    debugPrint('');
    debugPrint('========================================');
    debugPrint('[$severityIcon] ${error.timestamp.toIso8601String()}');
    debugPrint('Message: ${error.message}');
    if (error.context != null) {
      debugPrint('Context: ${error.context}');
    }
    if (error.error != null) {
      debugPrint('Error: ${error.error}');
    }
    if (error.stackTrace != null) {
      debugPrint('Stack trace:');
      debugPrint(error.stackTrace.toString());
    }
    debugPrint('========================================');
    debugPrint('');
  }

  /// Clear recent errors
  void clearRecentErrors() {
    _recentErrors.clear();
  }

  /// Dispose of resources
  void dispose() {
    _errorController.close();
  }
}
