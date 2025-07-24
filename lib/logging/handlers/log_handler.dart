import '../log_level.dart';

/// Interface for log handlers that process log messages.
abstract class LogHandler {
  /// Logs a message with the specified level and optional metadata.
  /// 
  /// [level] The severity level of the log message.
  /// [message] The message to log.
  /// [source] Optional source identifier (e.g., client name, agent name).
  /// [metadata] Optional additional data related to the log entry.
  void log(LogLevel level, String message, {String? source, Map<String, dynamic>? metadata});
  
  /// Closes the handler and releases any resources.
  void close();
}