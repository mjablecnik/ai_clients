import 'dart:convert';
import 'package:ai_clients/src/tokens.dart';

class Context {
  final String? name;
  final String value;

  const Context({this.name, required this.value});
}

class Parameter {
  final String name;
  final String type;
  final String description;
  final bool required;
  final List<String>? enumValues;

  const Parameter({
    required this.name,
    required this.type,
    required this.description,
    this.required = false,
    this.enumValues,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      required: json['required'] ?? false,
      enumValues: (json['enum'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'type': type,
      'description': description,
      'required': required,
    };
    if (enumValues != null) {
      map['enum'] = enumValues as Object;
    }
    return map;
  }
}

class Tool {
  final String name;
  final String description;
  final Function function;
  final List<Parameter> parameters;
  final Map<String, dynamic> arguments;

  const Tool({
    required this.name,
    required this.description,
    required this.function,
    this.parameters = const [],
    this.arguments = const {},
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'parameters': parameters.map((p) => p.toJson()).toList(),
  };

  dynamic call() {
    return function(arguments);
  }

  Tool copyWith({
    String? name,
    String? description,
    Function? function,
    List<Parameter>? parameters,
    Map<String, dynamic>? arguments,
  }) {
    return Tool(
      name: name ?? this.name,
      description: description ?? this.description,
      function: function ?? this.function,
      parameters: parameters ?? this.parameters,
      arguments: arguments ?? this.arguments,
    );
  }
}

class AiClientResponse {
  final String id;
  final String role;
  final String message;
  final TokenUsage tokenUsage;
  final List<Tool> tools;

  const AiClientResponse({
    required this.id,
    required this.role,
    required this.message,
    required this.tokenUsage,
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
          tool.copyWith(arguments: jsonDecode(t['function']['arguments']));
          tools.add(tool);
        }
      }

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
        tools: tools,
      );
    } else {
      throw Exception('No response from ChatGPT API.');
    }
  }

  @override
  String toString() {
    return 'AiClientResponse(id: $id, role: $role, message: $message, tokenUsage: $tokenUsage, tools: $tools)';
  }
}

