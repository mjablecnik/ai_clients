import 'package:ai_clients/models.dart';

abstract class AiClient {
  final Duration? delay;

  AiClient({String? apiUrl, String? apiKey, String? model, this.delay = const Duration(milliseconds: 300)});

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
}
