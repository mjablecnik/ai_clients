import 'package:ai_clients/ai_clients.dart';

import 'models/message.dart';

class AiAgent {
  final AiClient client;
  final List<Tool> tools;
  final String description;
  final bool enableHistory;

  const AiAgent({required this.client, required this.tools, required this.description, this.enableHistory = true});

  void sendMessage(Message message, {List<Context> context = const []}) {}
}
