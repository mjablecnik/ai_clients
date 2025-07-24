import 'dart:convert';

import 'package:ai_clients/ai_clients.dart';

class AiAgent {
  final AiClient client;
  final List<Tool> tools;
  final String description;

  final List<Message> _historyMessages = [];

  AiAgent({required this.client, required this.description, this.tools = const []});

  Future<Message> sendMessage(Message message, {List<Context> context = const []}) async {

    AiClientResponse response = await client.query(
      system: description,
      history: _historyMessages,
      message: message,
      contexts: context,
      tools: tools,
      delay: client.delay,
    );

    addIntoHistory(
      Message(
        type: message.type,
        content: buildPrompt(prompt: message.content, contexts: context),
      ),
    );

    final Message responseMessage;

    if (response is ToolResponse) {
      addIntoHistory(Message.toolCall(response.rawMessage!));

      final toolCalls = (jsonDecode(response.rawMessage!) as List);
      final toolCallMessages = await client.makeToolCalls(tools: tools, toolCalls: toolCalls);
      final lastMessage = toolCallMessages.removeLast();
      _historyMessages.addAll(toolCallMessages);
      responseMessage = await sendMessage(lastMessage);
    } else {
      responseMessage = Message.assistant(response.message!);
      addIntoHistory(responseMessage);
    }

    return responseMessage;
  }

  void addIntoHistory(Message message) {
    _historyMessages.add(message);
    //print(message);
  }

  void clearHistory() {
    _historyMessages.clear();
  }

  void showHistory() {
    print(_historyMessages);
  }
}
