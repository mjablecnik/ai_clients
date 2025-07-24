import 'dart:convert';

import 'package:ai_clients/ai_clients.dart';

void main() async {
  var aiClient = AiClients.gemini();
  
  // Simple query example
  var simpleResponse = await aiClient.simpleQuery(
    model: "gemini-2.0-flash",
    system: "Jsi AI asistent a komunikuješ v češtině",
    prompt: "řekni mi vtip",
  );

  print('\nSimple Response:');
  print(simpleResponse);

  // Query with tools example
  var clientResponse = await aiClient.query(
    model: "gemini-2.0-flash",
    system: "Jsi AI asistent a komunikuješ v češtině",
    prompt: "řekni mi jaké je teď počasí",
    tools: [
      Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
    ],
  );

  print('\nAi Client Response:');
  print(clientResponse);

  if (clientResponse.message != null && clientResponse.message!.isNotEmpty) {
    print('\nResponse:');
    print(clientResponse.message);
  }

  if (clientResponse.tools.isNotEmpty) {
    print('\nTool Response:');
    final response = await clientResponse.tools.first.call({});
    print(response);

    if (response.isNotEmpty) {
      var geminiResponse2 = await aiClient.query(
        model: "gemini-2.0-flash",
        system: "Jsi AI asistent a komunikuješ v češtině",
        history: [Message.user("řekni mi jaké je teď počasí")],
        prompt: response,
        role: 'tool',
        tools: [
          Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
        ],
      );
      print('\nFinal Response:');
      print(geminiResponse2.message);
    } else {
      print("No response");
    }
  }
}

Future<String> getWeatherInformation(Map<String, dynamic> json) async {
  return Future.value(
    jsonEncode({
      "date": "2025-07-14",
      "location": "Prague",
      "temperature": {"min": 18, "max": 27, "unit": "°C"},
      "weather_condition": "partly cloudy",
      "precipitation": {"probability": 20, "unit": "%"},
      "humidity": 65,
      "wind": {"speed": 12, "direction": "NW", "unit": "km/h"},
    }),
  );
}