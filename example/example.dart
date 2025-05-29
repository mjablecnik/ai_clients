import 'package:ai_clients/ai_clients.dart';

void main() async {
  const prompt = 'Hello, how are you?';

  // BasetenClient example
  var basetenClient = BasetenClient();
  var basetenResponse = await basetenClient.query(prompt: prompt);
  print('BasetenClient response: $basetenResponse');

  // OpenAiClient example
  var openAiClient = OpenAiClient();
  var openAiResponse = await openAiClient.query(prompt: prompt);
  print('OpenAiClient response: $openAiResponse');

  // TogetherClient example
  var togetherClient = TogetherClient();
  var togetherResponse = await togetherClient.query(prompt: prompt);
  print('TogetherClient response: $togetherResponse');
}
