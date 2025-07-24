import 'log_level.dart';

/// Configuration for the logging system.
class LogConfig {
  /// Whether logging is enabled globally.
  final bool enabled;

  /// The minimum log level to display.
  final LogLevel globalLevel;

  /// Whether to log AI client operations.
  final bool enableClientLogs;

  /// Whether to log AI agent operations.
  final bool enableAgentLogs;

  /// Whether to log tool operations.
  final bool enableToolLogs;

  /// Whether to output logs to the console.
  final bool enableConsoleOutput;

  /// Whether to output logs to a file.
  final bool enableFileOutput;

  /// The path to the log file (required if enableFileOutput is true).
  final String? logFilePath;

  /// Creates a new log configuration.
  const LogConfig({
    this.enabled = false,
    this.globalLevel = LogLevel.info,
    this.enableClientLogs = true,
    this.enableAgentLogs = true,
    this.enableToolLogs = true,
    this.enableConsoleOutput = true,
    this.enableFileOutput = false,
    this.logFilePath,
  }) : assert(!enableFileOutput || (enableFileOutput && logFilePath != null),
            'logFilePath must be provided when enableFileOutput is true');

  /// Creates a disabled log configuration.
  factory LogConfig.disabled() => const LogConfig(enabled: false);

  /// Creates a log configuration with only console output enabled.
  factory LogConfig.consoleOnly({
    LogLevel level = LogLevel.info,
    bool enableClientLogs = true,
    bool enableAgentLogs = true,
    bool enableToolLogs = true,
  }) =>
      LogConfig(
        enabled: true,
        globalLevel: level,
        enableClientLogs: enableClientLogs,
        enableAgentLogs: enableAgentLogs,
        enableToolLogs: enableToolLogs,
        enableConsoleOutput: true,
        enableFileOutput: false,
      );

  /// Creates a log configuration with only file output enabled.
  factory LogConfig.fileOnly({
    required String filePath,
    LogLevel level = LogLevel.info,
    bool enableClientLogs = true,
    bool enableAgentLogs = true,
    bool enableToolLogs = true,
  }) =>
      LogConfig(
        enabled: true,
        globalLevel: level,
        enableClientLogs: enableClientLogs,
        enableAgentLogs: enableAgentLogs,
        enableToolLogs: enableToolLogs,
        enableConsoleOutput: false,
        enableFileOutput: true,
        logFilePath: filePath,
      );

  /// Creates a log configuration with both console and file output enabled.
  factory LogConfig.both({
    required String filePath,
    LogLevel level = LogLevel.info,
    bool enableClientLogs = true,
    bool enableAgentLogs = true,
    bool enableToolLogs = true,
  }) =>
      LogConfig(
        enabled: true,
        globalLevel: level,
        enableClientLogs: enableClientLogs,
        enableAgentLogs: enableAgentLogs,
        enableToolLogs: enableToolLogs,
        enableConsoleOutput: true,
        enableFileOutput: true,
        logFilePath: filePath,
      );

  /// Creates a copy of this configuration with the specified changes.
  LogConfig copyWith({
    bool? enabled,
    LogLevel? globalLevel,
    bool? enableClientLogs,
    bool? enableAgentLogs,
    bool? enableToolLogs,
    bool? enableConsoleOutput,
    bool? enableFileOutput,
    String? logFilePath,
  }) {
    return LogConfig(
      enabled: enabled ?? this.enabled,
      globalLevel: globalLevel ?? this.globalLevel,
      enableClientLogs: enableClientLogs ?? this.enableClientLogs,
      enableAgentLogs: enableAgentLogs ?? this.enableAgentLogs,
      enableToolLogs: enableToolLogs ?? this.enableToolLogs,
      enableConsoleOutput: enableConsoleOutput ?? this.enableConsoleOutput,
      enableFileOutput: enableFileOutput ?? this.enableFileOutput,
      logFilePath: logFilePath ?? this.logFilePath,
    );
  }
}