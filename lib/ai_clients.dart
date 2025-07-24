library;

export 'agents.dart';
export 'clients.dart';
export 'models.dart';
export 'utils.dart';

export 'mcp/ai_mcp_client.dart';

import 'package:ai_clients/logging/logger.dart';

import 'clients/baseten_client.dart';
import 'clients/gemini_client.dart';
import 'clients/openai_client.dart';
import 'clients/together_client.dart';

class AiClients {
  static OpenAiClient openAi({String? apiUrl, String? apiKey, String? model, Duration? delay, Logger? logger}) {
    return OpenAiClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay, logger: logger);
  }

  static TogetherClient together({String? apiUrl, String? apiKey, String? model, Duration? delay, Logger? logger}) {
    return TogetherClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay, logger: logger);
  }

  static BasetenClient baseten({String? apiUrl, String? apiKey, String? model, Duration? delay, Logger? logger}) {
    return BasetenClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay, logger: logger);
  }

  static GeminiClient gemini({String? apiUrl, String? apiKey, String? model, Duration? delay, Logger? logger}) {
    return GeminiClient(apiUrl: apiUrl, apiKey: apiKey, model: model, delay: delay, logger: logger);
  }
}
