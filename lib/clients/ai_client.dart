import 'dart:convert';

import 'package:ai_clients/models.dart';
import 'package:ai_clients/logging/logging.dart';

abstract class AiClient {
  final Duration? delay;
  final Logger _logger;

  AiClient({
    String? apiUrl,
    String? apiKey,
    String? model,
    this.delay = const Duration(milliseconds: 300),
    Logger? logger,
  }) : _logger = logger ?? Logger();

  Future<String> simpleQuery({
    String? model,
    List<Message> history = const [],
    Duration? delay,
    required String prompt,
    String? system,
    String role = 'user',
    List<Context>? contexts,
  }) async {
    final result = await query(
      model: model,
      delay: delay,
      history: history,
      system: system,
      contexts: contexts,
      message: Message(type: MessageType.values.byName(role), content: prompt),
    );
    return result.message!;
  }

  Future<AiClientResponse> query({
    required Message message,
    List<Message> history = const [],
    String? system,
    String? model,
    Duration? delay,
    List<Context>? contexts,
    List<Tool> tools = const [],
  });

  Future<List<ToolResultMessage>> makeToolCalls({required List<Tool> tools, required List toolCalls});

  /// Logs a request being sent to the AI provider.
  void logRequest(Map<String, dynamic> data) {
    _logger.clientLog(
      LogLevel.info,
      jsonEncode(data),
      clientName: runtimeType.toString(),
    );
  }

  /// Logs a response received from the AI provider.
  void logResponse(Map<String, dynamic> response) {
    _logger.clientLog(
      LogLevel.info,
      jsonEncode(response),
      clientName: runtimeType.toString(),
    );
  }

  /// Logs an error that occurred during a request.
  void logError(dynamic error) {
    _logger.clientLog(
      LogLevel.error,
      'Error: ${error.toString()}',
      clientName: runtimeType.toString(),
    );
  }
}
