import 'package:ai_clients/models.dart';

abstract class AiClient {
  AiClient({String? apiUrl, String? apiKey});

  Future<String> simpleQuery({
    required String prompt,
    String? system,
    List<Context>? contexts,
    String model,
    Duration delay = Duration.zero,
  });

  Future<AiClientResponse> query({
    required String prompt,
    String? system,
    String model,
    Duration delay = Duration.zero,
    List<Context>? contexts,
    List<Tool>? tools,
  });
}
