library;

export 'agents.dart';
export 'clients.dart';
export 'models.dart';
export 'utils.dart';

import 'clients/baseten_client.dart';
import 'clients/gemini_client.dart';
import 'clients/openai_client.dart';
import 'clients/together_client.dart';

class AiClients {
  static OpenAiClient openAi({String? apiUrl, String? apiKey, String? model, Duration? delay}) {
    return OpenAiClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay);
  }

  static TogetherClient together({String? apiUrl, String? apiKey, String? model, Duration? delay}) {
    return TogetherClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay);
  }

  static BasetenClient baseten({String? apiUrl, String? apiKey, String? model, Duration? delay}) {
    return BasetenClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay);
  }

  static GeminiClient gemini({String? apiUrl, String? apiKey, String? model, Duration? delay}) {
    return GeminiClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay);
  }
}
