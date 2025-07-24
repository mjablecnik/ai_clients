import 'dart:io';

import '../log_level.dart';
import 'log_handler.dart';

/// A log handler that outputs log messages to a file.
class FileLogHandler implements LogHandler {
  final File _file;
  IOSink? _sink;
  
  /// Creates a new file log handler.
  /// 
  /// [filePath] The path to the log file.
  FileLogHandler(String filePath) : _file = File(filePath) {
    try {
      // Create directory if it doesn't exist
      final dir = Directory(_file.parent.path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      // Open file for writing in append mode
      _sink = _file.openWrite(mode: FileMode.append);
    } catch (e) {
      print('Error initializing file logger: $e');
      rethrow;
    }
  }
  
  @override
  void log(LogLevel level, String message, {String? source, Map<String, dynamic>? metadata}) {
    if (_sink == null) return;
    
    try {
      final timestamp = DateTime.now().toIso8601String();
      final sourceStr = source != null ? '[$source] ' : '';
      final levelStr = level.name;
      
      _sink!.writeln('$timestamp [$levelStr] $sourceStr$message');
      
      // Log metadata if available
      if (metadata != null && metadata.isNotEmpty) {
        _sink!.writeln('  Metadata: $metadata');
      }
    } catch (e) {
      print('Error writing to log file: $e');
    }
  }
  
  @override
  void close() {
    try {
      _sink?.flush();
      _sink?.close();
      _sink = null;
    } catch (e) {
      print('Error closing log file: $e');
    }
  }
}