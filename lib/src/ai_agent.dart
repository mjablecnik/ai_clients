import 'package:ai_clients/ai_clients.dart';

import '../models/message.dart';

class AiAgent {
  final AiClient client;
  final List<Tool> tools;
  final String description;

  final ChatHistory _history = ChatHistory();

  AiAgent({required this.client, required this.description, this.tools = const []});

  Future<Message> sendMessage(Message message, {List<Context> context = const []}) async {
    _history.addMessage(
      Message(
        type: message.type,
        content: buildPrompt(prompt: message.content, contexts: context),
      ),
    );

    AiClientResponse response = await client.query(
      system: description,
      history: _history.messages,
      prompt: message.content,
      contexts: context,
      tools: tools,
      delay: Duration(seconds: 1),
    );

    final List<Context> toolCallResults = [];
    final Message responseMessage;

    if (response is ToolResponse) {
      _history.addMessage(Message.assistant(response.rawMessage!));

      for (final tool in response.tools) {
        final value = await tool.call();
        toolCallResults.add(Context(name: tool.name, value: value));
      }

      responseMessage = await sendMessage(Message.toolsCall(''), context: toolCallResults);
    } else {
      responseMessage = Message.assistant(response.message!);
    }

    _history.addMessage(responseMessage);

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
