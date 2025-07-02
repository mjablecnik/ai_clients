import 'package:ai_clients/ai_clients.dart';

import 'models/message.dart';

class AiAgent {
  final AiClient client;
  final List<Tool> tools;
  final String description;
  final bool enableHistory;

  final ChatHistory _history = const ChatHistory();

  const AiAgent({required this.client, required this.tools, required this.description, this.enableHistory = true});

  Future<Message> sendMessage(Message message, {List<Context> context = const []}) async {
    if (enableHistory) _history.addMessage(message);

    AiClientResponse response = await client.query(
      prompt: message.content,
      contexts: context,
      tools: tools,
      system: description,
    );

    final responseMessage = Message.assistant(response.message);

    if (enableHistory) _history.addMessage(responseMessage);

    return responseMessage;
  }

  void clearHistory() {
    _history.clear();
  }
}

class ChatHistory {
  final List<Message> messages;

  const ChatHistory({this.messages = const []});

  void addMessage(Message message) {
    messages.add(message);
  }

  void clear() {
    messages.clear();
  }
}
