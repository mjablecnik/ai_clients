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
  static OpenAiClient openAi({String? apiUrl, String? apiKey}) {
    return OpenAiClient(apiUrl: apiUrl, apiKey: apiKey);
  }

  static TogetherClient together({String? apiUrl, String? apiKey}) {
    return TogetherClient(apiUrl: apiUrl, apiKey: apiKey);
  }

  static BasetenClient baseten({String? apiUrl, String? apiKey}) {
    return BasetenClient(apiUrl: apiUrl, apiKey: apiKey);
  }
}
