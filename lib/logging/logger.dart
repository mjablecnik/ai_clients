import 'log_config.dart';
import 'log_level.dart';
import 'handlers/console_handler.dart';
import 'handlers/file_handler.dart';
import 'handlers/log_handler.dart';

/// The main logger class that manages logging operations.
class Logger {
  static Logger? _instance;
  
  /// The current logging configuration.
  LogConfig config;
  
  /// The list of active log handlers.
  final List<LogHandler> _handlers = [];
  
  /// Creates a new logger with the specified configuration.
  /// 
  /// This constructor is private to enforce the singleton pattern.
  Logger._internal(this.config) {
    _initializeHandlers();
  }
  
  /// Gets the singleton instance of the logger.
  /// 
  /// If [config] is provided, it will update the logger's configuration.
  factory Logger({LogConfig? config}) {
    _instance ??= Logger._internal(config ?? LogConfig.disabled());
    
    if (config != null && _instance != null) {
      _instance!.updateConfig(config);
    }
    
    return _instance!;
  }
  
  /// Initializes the log handlers based on the current configuration.
  void _initializeHandlers() {
    // Close and clear existing handlers
    for (final handler in _handlers) {
      handler.close();
    }
    _handlers.clear();
    
    // Add console handler if enabled
    if (config.enabled && config.enableConsoleOutput) {
      _handlers.add(ConsoleLogHandler());
    }
    
    // Add file handler if enabled and path provided
    if (config.enabled && config.enableFileOutput && config.logFilePath != null) {
      _handlers.add(FileLogHandler(config.logFilePath!));
    }
  }
  
  /// Updates the logger's configuration.
  void updateConfig(LogConfig newConfig) {
    config = newConfig;
    _initializeHandlers();
  }
  
  /// Logs a debug message.
  void debug(String message, {String? source, Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, source: source, metadata: metadata);
  }
  
  /// Logs an info message.
  void info(String message, {String? source, Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, source: source, metadata: metadata);
  }
  
  /// Logs a warning message.
  void warning(String message, {String? source, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warning, message, source: source, metadata: metadata);
  }
  
  /// Logs an error message.
  void error(String message, {String? source, Map<String, dynamic>? metadata}) {
    _log(LogLevel.error, message, source: source, metadata: metadata);
  }
  
  /// Logs a message for an AI client.
  void clientLog(LogLevel level, String message, {String? clientName, Map<String, dynamic>? metadata}) {
    if (!config.enabled || !config.enableClientLogs) return;
    _log(level, message, source: 'Client:${clientName ?? "Unknown"}', metadata: metadata);
  }
  
  /// Logs a message for an AI agent.
  void agentLog(LogLevel level, String message, {String? agentName, Map<String, dynamic>? metadata}) {
    if (!config.enabled || !config.enableAgentLogs) return;
    _log(level, message, source: 'Agent:${agentName ?? "Unknown"}', metadata: metadata);
  }
  
  /// Logs a message for a tool.
  void toolLog(LogLevel level, String message, {String? toolName, Map<String, dynamic>? metadata}) {
    if (!config.enabled || !config.enableToolLogs) return;
    _log(level, message, source: 'Tool:${toolName ?? "Unknown"}', metadata: metadata);
  }
  
  /// Internal method to log a message with the specified level and metadata.
  void _log(LogLevel level, String message, {String? source, Map<String, dynamic>? metadata}) {
    if (!config.enabled || level.value < config.globalLevel.value) return;
    
    for (final handler in _handlers) {
      handler.log(level, message, source: source, metadata: metadata);
    }
  }
  
  /// Closes all handlers and releases resources.
  void close() {
    for (final handler in _handlers) {
      handler.close();
    }
    _handlers.clear();
  }
}