import 'package:ai_clients/ai_clients.dart';

void main() async {
  var client = OpenAiClient();
  var response = await client.query(prompt: 'Hello, how are you?');
  print(response);
}
