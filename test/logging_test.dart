import 'dart:io';
import 'package:test/test.dart';
import 'package:ai_clients/ai_clients.dart';

void main() {
  group('Logger tests', () {
    late Logger logger;
    late File testLogFile;
    final testLogPath = 'test_logs.txt';

    setUp(() {
      // Create a new logger instance for each test
      logger = Logger();
      testLogFile = File(testLogPath);
      
      // Make sure we start with a clean state
      if (testLogFile.existsSync()) {
        testLogFile.deleteSync();
      }
    });

    tearDown(() {
      // Clean up after each test
      logger.updateConfig(LogConfig.disabled());
      if (testLogFile.existsSync()) {
        testLogFile.deleteSync();
      }
    });

    test('Logger should be disabled by default', () {
      expect(logger.config.enabled, isFalse);
    });

    test('Logger should respect log levels', () {
      // Configure logger to only show warning and above
      logger.updateConfig(LogConfig(
        enabled: true,
        globalLevel: LogLevel.warning,
        enableConsoleOutput: false,
        enableFileOutput: true,
        logFilePath: testLogPath,
      ));

      // These should not be logged
      logger.debug('Debug message');
      logger.info('Info message');
      
      // These should be logged
      logger.warning('Warning message');
      logger.error('Error message');

      // Read the log file
      final logContent = testLogFile.readAsStringSync();
      
      // Verify content
      expect(logContent.contains('DEBUG'), isFalse);
      expect(logContent.contains('INFO'), isFalse);
      expect(logContent.contains('WARNING'), isTrue);
      expect(logContent.contains('ERROR'), isTrue);
    });

    test('Logger should handle component-specific logging', () {
      // Configure logger
      logger.updateConfig(LogConfig(
        enabled: true,
        globalLevel: LogLevel.debug,
        enableClientLogs: true,
        enableAgentLogs: false, // Disable agent logs
        enableToolLogs: true,
        enableConsoleOutput: false,
        enableFileOutput: true,
        logFilePath: testLogPath,
      ));

      // Log messages for different components
      logger.clientLog(LogLevel.info, 'Client message', clientName: 'TestClient');
      logger.agentLog(LogLevel.info, 'Agent message', agentName: 'TestAgent');
      logger.toolLog(LogLevel.info, 'Tool message', toolName: 'TestTool');

      // Read the log file
      final logContent = testLogFile.readAsStringSync();
      
      // Verify content
      expect(logContent.contains('Client:TestClient'), isTrue);
      expect(logContent.contains('Agent:TestAgent'), isFalse); // Should be disabled
      expect(logContent.contains('Tool:TestTool'), isTrue);
    });

    test('Logger should handle metadata', () {
      // Configure logger
      logger.updateConfig(LogConfig(
        enabled: true,
        globalLevel: LogLevel.info,
        enableConsoleOutput: false,
        enableFileOutput: true,
        logFilePath: testLogPath,
      ));

      // Log with metadata
      final metadata = {'key1': 'value1', 'key2': 42};
      logger.info('Message with metadata', metadata: metadata);

      // Read the log file
      final logContent = testLogFile.readAsStringSync();
      
      // Verify content
      expect(logContent.contains('Message with metadata'), isTrue);
      expect(logContent.contains('Metadata:'), isTrue);
      expect(logContent.contains('key1'), isTrue);
      expect(logContent.contains('value1'), isTrue);
      expect(logContent.contains('key2'), isTrue);
      expect(logContent.contains('42'), isTrue);
    });
  });
}