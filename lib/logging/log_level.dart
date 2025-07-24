/// Defines the severity levels for logging.
enum LogLevel {
  /// Detailed information, typically useful for debugging.
  debug,

  /// General information about system operation.
  info,

  /// Potentially harmful situations that might cause issues.
  warning,

  /// Error events that might still allow the application to continue.
  error,

  /// No logging at all.
  none;

  /// Returns the numeric value of the log level for comparison.
  int get value {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.error:
        return 3;
      case LogLevel.none:
        return 4;
    }
  }

  /// Checks if this log level should be logged given a minimum level.
  bool shouldLog(LogLevel minimumLevel) {
    return this.value >= minimumLevel.value;
  }

  /// Returns the string representation of the log level.
  String get name => toString().split('.').last.toUpperCase();
}