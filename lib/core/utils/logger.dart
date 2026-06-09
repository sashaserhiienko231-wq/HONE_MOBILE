import 'package:flutter/foundation.dart';

/// Production-safe logging system
/// Provides structured logging with release-mode safety
class Logger {
  static Logger? _instance;
  static Logger get instance => _instance ??= Logger._();

  Logger._();

  bool _isProduction = false;
  final List<LogEntry> _logs = [];
  static const int _maxLogEntries = 1000;

  /// Initialize logger
  void initialize({bool isProduction = false}) {
    _isProduction = isProduction;
  }

  /// Log debug message (only in debug mode)
  void debug(String message, {String? tag}) {
    if (!_isProduction && kDebugMode) {
      _log(LogLevel.debug, message, tag: tag);
      debugPrint('[${tag ?? "DEBUG"}] $message');
    }
  }

  /// Log info message
  void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
    if (!_isProduction || kDebugMode) {
      debugPrint('[${tag ?? "INFO"}] $message');
    }
  }

  /// Log warning message
  void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
    debugPrint('[${tag ?? "WARN"}] $message');
  }

  /// Log error message
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
    debugPrint('[${tag ?? "ERROR"}] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log critical message (always logged)
  void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
    debugPrint('[${tag ?? "CRITICAL"}] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log startup specific message
  void startup(String message, {String? tag}) {
    _log(LogLevel.startup, message, tag: tag ?? 'STARTUP');
    if (!_isProduction || kDebugMode) {
      debugPrint('[STARTUP] $message');
    }
  }

  /// Add log entry
  void _log(LogLevel level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      timestamp: DateTime.now(),
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    _logs.add(entry);

    // Keep log size bounded
    if (_logs.length > _maxLogEntries) {
      _logs.removeAt(0);
    }
  }

  /// Get all logs
  List<LogEntry> getLogs({LogLevel? filterLevel}) {
    if (filterLevel == null) {
      return List.from(_logs);
    }
    return _logs.where((log) => log.level == filterLevel).toList();
  }

  /// Get recent logs
  List<LogEntry> getRecentLogs({int count = 50}) {
    return _logs.skip(_logs.length - count).toList();
  }

  /// Clear logs
  void clearLogs() {
    _logs.clear();
  }

  /// Export logs to string
  String exportLogs() {
    final buffer = StringBuffer();
    for (final log in _logs) {
      buffer.writeln(log.toString());
    }
    return buffer.toString();
  }
}

/// Log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final DateTime timestamp;
  final String? error;
  final String? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('${timestamp.toIso8601String()} [${level.name.toUpperCase()}]');
    if (tag != null) buffer.writeln('Tag: $tag');
    buffer.writeln('Message: $message');
    if (error != null) buffer.writeln('Error: $error');
    if (stackTrace != null) buffer.writeln('StackTrace: $stackTrace');
    return buffer.toString();
  }
}

/// Log level
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
  startup,
}

/// Extension for log level
extension LogLevelExtension on LogLevel {
  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
      case LogLevel.startup:
        return '🚀';
    }
  }
}
