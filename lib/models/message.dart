sealed class Message {
  final String type;
  final String content;

  const Message({required this.type, required this.content});

  factory Message.user(String content) => UserMessage(content: content);

  factory Message.assistant(String content) => AssistantMessage(content: content);

  factory Message.toolsCall(String content) => ToolsCallMessage(content: content);

  factory Message.system(String content) => SystemMessage(content: content);

  @override
  String toString() {
    return 'Message(type: $type, content: $content)';
  }
}

class UserMessage extends Message {
  UserMessage({required super.content}) : super(type: 'user');
}

class AssistantMessage extends Message {
  final String? tools;
  AssistantMessage({required super.content, this.tools}) : super(type: 'assistant');
}

class ToolsCallMessage extends Message {
  ToolsCallMessage({required super.content}) : super(type: 'tool');
}

class SystemMessage extends Message {
  SystemMessage({required super.content}) : super(type: 'system');
}
