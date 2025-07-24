import 'package:ai_clients/ai_clients.dart';
import 'package:ai_clients/logging/logging.dart';

void main() async {
  // Example 1: Basic logging with console output
  setupBasicLogging();
  
  // Example 2: Advanced logging configuration
  setupAdvancedLogging();
  
  // Example 3: Using logging with AI clients
  await usingLoggingWithAiClients();
}

void setupBasicLogging() {
  print('\n=== Basic Logging Example ===\n');
  
  // Get the singleton logger instance
  final logger = Logger();
  
  // Enable logging with console output only
  logger.updateConfig(LogConfig.consoleOnly(
    level: LogLevel.debug,  // Show all log levels
  ));
  
  // Log messages at different levels
  logger.debug('This is a debug message');
  logger.info('This is an info message');
  logger.warning('This is a warning message');
  logger.error('This is an error message');
  
  // Disable logging
  logger.updateConfig(LogConfig.disabled());
  logger.info('This message will not be displayed because logging is disabled');
}

void setupAdvancedLogging() {
  print('\n=== Advanced Logging Example ===\n');
  
  final logger = Logger();
  
  // Configure logging with both console and file output
  logger.updateConfig(LogConfig(
    enabled: true,
    globalLevel: LogLevel.info,  // Only show info level and above
    enableClientLogs: true,
    enableAgentLogs: true,
    enableToolLogs: true,
    enableConsoleOutput: true,
    enableFileOutput: true,
    logFilePath: 'ai_clients_logs.txt',
  ));
  
  // Log messages with metadata
  logger.info(
    'Processing request',
    source: 'ExampleApp',
    metadata: {'requestId': '12345', 'user': 'test_user'},
  );
  
  // Component-specific logging
  logger.clientLog(
    LogLevel.info,
    'API request completed',
    clientName: 'OpenAI',
    metadata: {'duration': '1.2s', 'tokens': 150},
  );
  
  logger.agentLog(
    LogLevel.warning,
    'Rate limit approaching',
    agentName: 'AssistantAgent',
    metadata: {'remaining': 10},
  );
  
  logger.toolLog(
    LogLevel.error,
    'Tool execution failed',
    toolName: 'Calculator',
    metadata: {'error': 'Division by zero'},
  );
}

Future<void> usingLoggingWithAiClients() async {
  print('\n=== Using Logging with AI Clients ===\n');
  
  // Enable logging
  final logger = Logger();
  logger.updateConfig(LogConfig.consoleOnly(level: LogLevel.info));
  
  try {
    // This will fail because we're not providing a valid API key,
    // but it will demonstrate the logging
    final client = AiClients.openAi();
    
    print('Sending a query to OpenAI (this will fail but show logs)...');
    await client.simpleQuery(prompt: 'Hello, world!');
  } catch (e) {
    print('Expected error: ${e.toString()}');
  }
  
  // Disable logging when done
  logger.updateConfig(LogConfig.disabled());
}