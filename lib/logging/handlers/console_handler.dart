import '../log_level.dart';
import 'log_handler.dart';

/// A log handler that outputs log messages to the console.
class ConsoleLogHandler implements LogHandler {
  /// Creates a new console log handler.
  ConsoleLogHandler();

  @override
  void log(LogLevel level, String message, {String? source, Map<String, dynamic>? metadata}) {
    final timestamp = DateTime.now().toIso8601String();
    final sourceStr = source != null ? '[$source] ' : '';
    final levelStr = level.name;
    
    print('$timestamp [$levelStr] $sourceStr$message\n');
    
    // Print metadata if available
    if (metadata != null && metadata.isNotEmpty) {
      print('  Metadata: $metadata');
    }
  }
  
  @override
  void close() {
    // No resources to close for console handler
  }
}