import 'package:ai_clients/ai_clients.dart';

import '../models/message.dart';

class AiAgent {
  final AiClient client;
  final List<Tool> tools;
  final String description;
  final bool enableHistory;

  final ChatHistory _history = ChatHistory();

  AiAgent({required this.client, required this.description, this.tools = const [], this.enableHistory = true});

  Future<Message> sendMessage(Message message, {List<Context> context = const []}) async {
    if (enableHistory) _history.addMessage(message);

    AiClientResponse response = await client.query(
      prompt: message.content,
      contexts: context,
      tools: tools,
      system: description,
    );


    final Message responseMessage;
    switch (response) {
      case ToolResponse():
        responseMessage = Message.toolsCall(response.rawMessage!);
      case AssistantResponse():
        responseMessage = Message.assistant(response.message!);
    }

    if (enableHistory) _history.addMessage(responseMessage);

    return responseMessage;
  }

  void clearHistory() {
    _history.clear();
  }

  void showHistory() {
    print(_history.messages);
  }
}

class ChatHistory {
  List<Message> messages = [];

  ChatHistory();

  void addMessage(Message message) {
    messages.add(message);
  }

  void clear() {
    messages.clear();
  }
}
