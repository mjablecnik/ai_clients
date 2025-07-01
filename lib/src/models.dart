import 'package:ai_clients/src/tokens.dart';

class Context {
  final String? name;
  final String value;

  const Context({this.name, required this.value});
}

class Tool {
  final String name;
  final String description;
  final String function;

  const Tool({required this.name, required this.description, required this.function});
}

class AiClientResponse {
  final String id;
  final String role;
  final String message;
  final TokenUsage tokenUsage;

  const AiClientResponse({required this.id, required this.role, required this.message, required this.tokenUsage});

  static AiClientResponse fromOpenAi(Map<String, dynamic> json) {
    final choices = json['choices'];
    if (choices != null && choices.isNotEmpty) {
      final choice = choices[0];
      final messageObj = choice['message'] ?? {};
      final id = json['id'] ?? '';
      final role = messageObj['role'] ?? 'assistant';
      final message = messageObj['content'] ?? '';
      final usage = json['usage'] ?? {};

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

      return AiClientResponse(
        id: id,
        role: role,
        message: message,
        tokenUsage: tokenUsage,
      );
    } else {
      throw Exception('No response from ChatGPT API.');
    }
  }
}
