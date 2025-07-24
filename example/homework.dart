import 'dart:convert';

import 'package:ai_clients/ai_clients.dart';

void main() async {
  final List<Message> history = [];
  final tools = [
    Tool(name: "getWeatherInformation", description: "Získá informace o počasí", function: getWeatherInformation),
  ];

  var aiClient = AiClients.together();

  final message = Message.user("řekni mi jaké je teď počasí");
  history.add(message);
  print('\nUser request:');
  print(message.content);

  var clientResponse = await aiClient.query(
    model: "meta-llama/Llama-3.3-70B-Instruct-Turbo",
    system: "Jsi AI asistent a komunikuješ v češtině",
    message: message,
    tools: tools,
  );

  print('\nAi Client Response:');
  print(clientResponse);


  if (clientResponse.message != null && clientResponse.message!.isNotEmpty) {
    print('\nResponse:');
    print(clientResponse.message);

    history.add(Message.assistant(clientResponse.message!));
  }

  if (clientResponse.tools.isNotEmpty) {
    history.add(Message.assistant(jsonEncode(clientResponse.tools)));

    print('\nTool Response:');
    final response = await clientResponse.tools.first.call({});
    print(response);

    if (response.isNotEmpty) {
      var clientResponse2 = await aiClient.query(
        model: "meta-llama/Llama-3.3-70B-Instruct-Turbo",
        system: "Jsi AI asistent a komunikuješ v češtině",
        message: Message.toolResult(null, response),
        history: history,
        tools: tools,
      );
      history.add(Message.toolResult(null, response));

      print('\nFinal Response:');
      print(clientResponse2.message);
      history.add(Message.assistant(clientResponse2.message!));
    } else {
      print("No response");
    }
  }

  print('\nChat history:');
  print(history);
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
