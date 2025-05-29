abstract class AiClient {
  AiClient({String? apiUrl, String? apiKey});

  Future<String> query({required String prompt, String? system, String? context, String model});
}
