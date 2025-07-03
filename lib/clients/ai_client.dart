import 'package:ai_clients/models.dart';

abstract class AiClient {
  AiClient({String? apiUrl, String? apiKey, String? model});

  Future<String> simpleQuery({
    String? model,
    List<Message> history = const [],
    Duration delay = Duration.zero,
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
    Duration delay = Duration.zero,
    List<Context>? contexts,
    List<Tool> tools = const [],
  });
}
