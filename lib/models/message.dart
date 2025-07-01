sealed class Message {
  final String type;
  final String content;

  const Message({required this.type, required this.content});

  factory Message.user(String content) => UserMessage(content: content);

  factory Message.assistant(String content) => AssistantMessage(content: content);

  factory Message.tool(String content) => ToolMessage(content: content);

  factory Message.system(String content) => SystemMessage(content: content);
}

class UserMessage extends Message {
  UserMessage({required super.content}) : super(type: 'user');
}

class AssistantMessage extends Message {
  AssistantMessage({required super.content}) : super(type: 'assistant');
}

class ToolMessage extends Message {
  ToolMessage({required super.content}) : super(type: 'tool');
}

class SystemMessage extends Message {
  SystemMessage({required super.content}) : super(type: 'system');
}
