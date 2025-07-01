import 'package:ai_clients/src/tokens.dart';

class Context {
  final String? name;
  final String value;

  const Context({this.name, required this.value});
}

class Tool {
  final String? name;
  final String function;

  const Tool({this.name, required this.function});
}

class AiClientResponse {
  final String id;
  final String role;
  final String message;
  final TokenUsage tokenUsage;

  const AiClientResponse({required this.id, required this.role, required this.message, required this.tokenUsage});
}
