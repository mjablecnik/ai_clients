import 'package:ai_clients/src/models.dart';

abstract class AiClient {
  AiClient({String? apiUrl, String? apiKey});

  Future<String> simpleQuery({
    required String prompt,
    String? system,
    List<Context>? contexts,
    String model,
    Duration delay = Duration.zero,
  });
}
