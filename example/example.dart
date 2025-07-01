import 'package:ai_clients/ai_clients.dart';

void main() async {
  const prompt = 'Hello, how are you?';

  // BasetenClient example
  var basetenClient = AiClients.baseten();
  var basetenResponse = await basetenClient.simpleQuery(prompt: prompt);
  print('BasetenClient response: $basetenResponse');

  // OpenAiClient example
  var openAiClient = AiClients.openAi();
  var openAiResponse = await openAiClient.simpleQuery(prompt: prompt);
  print('OpenAiClient response: $openAiResponse');

  // TogetherClient example
  var togetherClient = AiClients.together();
  var togetherResponse = await togetherClient.simpleQuery(prompt: prompt);
  print('TogetherClient response: $togetherResponse');
}
