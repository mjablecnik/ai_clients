import 'dart:convert';
import 'package:ai_clients/models/tool.dart';

//import 'package:ai_clients/models/tokens/prompt_tokens_details.dart';
//import 'package:ai_clients/models/tokens/token_details.dart';
//import 'package:ai_clients/models/tokens/token_usage.dart';

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

  //final TokenUsage tokenUsage;
  final List<Tool> tools;

  const AiClientResponse({
    required this.id,
    required this.role,
    this.message,
    this.rawMessage,
    //required this.tokenUsage,
    this.tools = const [],
  });

  static AiClientResponse fromOpenAi(Map<String, dynamic> json, {required List<Tool> originalTools}) {
    final choices = json['choices'];
    if (choices != null && choices.isNotEmpty) {
      final choice = choices[0];
      final messageObj = choice['message'] ?? {};
      final id = json['id'] ?? '';
      final role = messageObj['role'] ?? 'assistant';
      final message = messageObj['content'] ?? '';
      final usage = json['usage'] ?? {};

      // Parse tools if present in the message
      List<Tool> tools = [];
      if (messageObj['tool_calls'] != null && messageObj['tool_calls'] is List) {
        for (var t in (messageObj['tool_calls'] as List)) {
          final name = (t as Map<String, dynamic>)['function']['name'];
          final tool = originalTools.firstWhere((tool) => tool.name == name);
          tool.arguments = jsonDecode(t['function']['arguments']);
          tools.add(tool);
        }
      }

      /*
      final tokenUsage = TokenUsage(
        promptTokens: usage['prompt_tokens'] ?? 0,
        completionTokens: usage['completion_tokens'] ?? 0,
        totalTokens: usage['total_tokens'] ?? 0,
        promptTokensDetails: usage['prompt_tokens_details'] != null
            ? PromptTokensDetails.fromJson(usage['prompt_tokens_details'])
            : const PromptTokensDetails(cachedTokens: 0, audioTokens: 0),
        completionTokensDetails: usage['completion_tokens_details'] != null
            ? TokenDetails.fromJson(usage['completion_tokens_details'])
            : const TokenDetails(
          reasoningTokens: 0,
          audioTokens: 0,
          acceptedPredictionTokens: 0,
          rejectedPredictionTokens: 0,
        ),
      );
      */

      final finishReason = choices[0]['finish_reason'];

      if (finishReason == 'tool_calls') {
        return ToolResponse(id: id, tools: tools, rawMessage: jsonEncode(messageObj['tool_calls']));
      } else if (finishReason == 'stop') {
        return AssistantResponse(id: id, message: message);
      } else {
        throw Exception('Unknown response role: $role.');
      }

    } else {
      throw Exception('No response from ChatGPT API.');
    }
  }

  @override
  String toString() {
    return 'AiClientResponse(id: $id, role: $role, message: $message, tools: $tools)';
  }
}
