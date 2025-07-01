import 'package:ai_clients/ai_clients.dart';

void main() async {
  const prompt = 'Hello, how are you?';

  /*
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
   */

  // OpenAiClient example
  var openAiClient = AiClients.openAi();
  var openAiResponse = await openAiClient.query(
    system: "Jsi AI asistent a komunikuješ v češtině",
    //prompt: "řekni mi s čím mi můžeš pomoci",
    prompt: "řekni mi jaké je teď počasí",
    tools: [
      Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
    ],
  );

  print('\nAi Client Response:');
  print(openAiResponse);

  String response = '';
  if (openAiResponse.message.isNotEmpty) {
    response = openAiResponse.message;
  }

  if (openAiResponse.tools.isNotEmpty) {
    print('\nTool Response:');
    response = openAiResponse.tools.first.call().toString();
    print(response);
  }

  if (response.isNotEmpty) {
    var openAiResponse2 = await openAiClient.query(
      system: "Jsi AI asistent a komunikuješ v češtině",
      //prompt: "řekni mi s čím mi můžeš pomoci",
      prompt: response,
      tools: [
        Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
      ],
    );
    print('\nFinal Response:');
    print(openAiResponse2.message);
  } else {
    print("No response");
  }
}

Map<String, dynamic> getWeatherInformation(Map<String, dynamic> json) {
  return {
    "date": "2025-07-01",
    "location": "Prague",
    "temperature": {"min": 18, "max": 27, "unit": "°C"},
    "weather_condition": "partly cloudy",
    "precipitation": {"probability": 20, "unit": "%"},
    "humidity": 65,
    "wind": {"speed": 12, "direction": "NW", "unit": "km/h"},
  };
}
