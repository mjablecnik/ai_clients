import 'package:ai_clients/models/tool.dart';

class AssistantResponse extends AiClientResponse {
  AssistantResponse({required super.id, required super.message, super.role = 'assistant'});
}

class ToolResponse extends AiClientResponse {
  ToolResponse({required super.id, required super.tools, super.role = 'tool', required super.rawMessage});
}

sealed class AiClientResponse {
  final String id;
  final String role;
  final String? message;
  final String? rawMessage;

  final List<Tool> tools;

  const AiClientResponse({
    required this.id,
    required this.role,
    this.message,
    this.rawMessage,
    this.tools = const [],
  });

  @override
  String toString() {
    return 'AiClientResponse(id: $id, role: $role, message: $message, tools: $tools)';
  }
}
