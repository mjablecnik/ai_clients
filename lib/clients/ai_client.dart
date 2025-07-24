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
      prompt: prompt,
      system: system,
      contexts: contexts,
      role: role,
    );
    return result.message!;
  }

  Future<AiClientResponse> query({
    required String prompt,
    List<Message> history = const [],
    String? system,
    String? model,
    String role = 'user',
    Duration? delay,
    List<Context>? contexts,
    List<Tool> tools = const [],
  });
}
