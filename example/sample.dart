import 'dart:convert';

import 'package:ai_clients/ai_clients.dart';

void main() async {
  final tools = [
    Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
  ];
  //var aiClient = AiClients.openAi(model: 'gpt-4o-mini');
  //var aiClient = AiClients.together(model: 'meta-llama/Llama-3.3-70B-Instruct-Turbo');
  //var aiClient = AiClients.gemini();
  var aiClient = AiClients.baseten();
  var aiAgent = AiAgent(client: aiClient, description: "Jsi AI asistent a komunikuješ v češtině", tools: tools);
  var response = await aiAgent.sendMessage(Message.user("řekni mi jaké je teď počasí"));

  print(response.content);
  print('\n');

  //aiAgent.showHistory();
}

Future<String> getWeatherInformation(Map<String, dynamic> json) async {
  return Future.value(
    jsonEncode({
      "date": "2025-07-01",
      "location": "Prague",
      "temperature": {"min": 18, "max": 27, "unit": "°C"},
      "weather_condition": "partly cloudy",
      "precipitation": {"probability": 20, "unit": "%"},
      "humidity": 65,
      "wind": {"speed": 12, "direction": "NW", "unit": "km/h"},
    }),
  );
}
