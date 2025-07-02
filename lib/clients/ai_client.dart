import 'package:ai_clients/models.dart';

abstract class AiClient {
  AiClient({String? apiUrl, String? apiKey, String? model});

  Future<String> simpleQuery({
    required String prompt,
    String? system,
    List<Context>? contexts,
    String model,
    String role = 'user',
    Duration delay = Duration.zero,
  });

  Future<AiClientResponse> query({
    required String prompt,
    String? system,
    String model,
    String role = 'user',
    Duration delay = Duration.zero,
    List<Context>? contexts,
    List<Tool>? tools,
  });

  Future<AiClientResponse> chat({
    required String prompt,
    String? system,
    String model,
    String role = 'user',
    Duration delay = Duration.zero,
    List<Context>? contexts,
    List<Tool>? tools,
    String historyKey = 'default',
  });
}
