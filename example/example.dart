import 'package:ai_clients/ai_clients.dart';

void main() async {
  var aiClient = AiClients.together();
  var clientResponse = await aiClient.chat(
    model: "meta-llama/Llama-3.3-70B-Instruct-Turbo",
    system: "Jsi AI asistent a komunikuješ v češtině",
    //prompt: "řekni mi vtip",
    prompt: "řekni mi jaké je teď počasí",
    tools: [
      Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
    ],
  );

  print('\nAi Client Response:');
  print(clientResponse);

  if (clientResponse.message.isNotEmpty) {
    print('\nResponse:');
    print(clientResponse.message);
  }

  if (clientResponse.tools.isNotEmpty) {
    print('\nTool Response:');
    final response = clientResponse.tools.first.call().toString();
    print(response);

    if (response.isNotEmpty) {
      var openAiResponse2 = await aiClient.chat(
        model: "meta-llama/Llama-3.3-70B-Instruct-Turbo",
        system: "Jsi AI asistent a komunikuješ v češtině",
        prompt: response,
        role: 'tool',
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

  print('\nChat history:');
  print(aiClient.history);
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
