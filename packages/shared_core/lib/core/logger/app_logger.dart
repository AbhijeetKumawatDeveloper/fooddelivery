import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

enum LogLevel { debug, info, warning, error }

abstract class AppLogger {
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });
}

class ConsoleAppLogger implements AppLogger {
  const ConsoleAppLogger();

  @override
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Suppress debug and info logs in production when enableDebugLogs is false
    final shouldLog =
        level == LogLevel.error ||
        level == LogLevel.warning ||
        AppConfig.instance.enableDebugLogs;

    if (!shouldLog) return;

    final prefix = _levelPrefix(level);
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final formattedMessage = '$prefix $tagPrefix$message';

    debugPrint(formattedMessage);

    if (error != null) {
      debugPrint('$prefix [ErrorDetails] $error');
    }
    if (stackTrace != null) {
      debugPrint('$prefix [StackTrace]\n$stackTrace');
    }
  }

  String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 [DEBUG]';
      case LogLevel.info:
        return 'ℹ️ [INFO]';
      case LogLevel.warning:
        return '⚠️ [WARN]';
      case LogLevel.error:
        return '🚨 [ERROR]';
    }
  }
}
