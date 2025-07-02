library;

import 'clients/baseten_client.dart';
import 'clients/openai_client.dart';
import 'clients/together_client.dart';

export 'clients/ai_client.dart';
export 'clients/baseten_client.dart';
export 'clients/openai_client.dart';
export 'clients/together_client.dart';
export 'utils.dart';
export 'models.dart';

class AiClients {
  static OpenAiClient openAi({String? apiUrl, String? apiKey, String? model}) {
    return OpenAiClient(apiUrl: apiUrl, apiKey: apiKey, model: model);
  }

  static TogetherClient together({String? apiUrl, String? apiKey, String? model}) {
    return TogetherClient(apiUrl: apiUrl, apiKey: apiKey, model: model);
  }

  static BasetenClient baseten({String? apiUrl, String? apiKey, String? model}) {
    return BasetenClient(apiUrl: apiUrl, apiKey: apiKey, model: model);
  }
}
