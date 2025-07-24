import 'dart:convert';

import 'package:ai_clients/ai_clients.dart';
import 'package:ai_clients/logging/logging.dart';

class AiAgent {
  final AiClient client;
  final List<Tool> tools;
  final String description;
  final Logger _logger;

  final List<Message> _historyMessages = [];

  AiAgent({required this.client, required this.description, this.tools = const [], Logger? logger})
    : _logger = logger ?? Logger() {
    _logger.agentLog(
      LogLevel.debug,
      'Agent initialized',
      agentName: runtimeType.toString(),
    );
  }

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
      message.type == MessageType.toolResult
          ? message
          : Message(
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

    _logger.agentLog(
      LogLevel.debug,
      message.toString(),
      agentName: runtimeType.toString(),
    );
  }

  void clearHistory() {
    _historyMessages.clear();
  }

  void showHistory() {
    print(_historyMessages);
  }
}
