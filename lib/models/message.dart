class Message {
  final String? id;
  final MessageType type;
  final String content;

  const Message({this.id, required this.type, required this.content});

  factory Message.user(String content) => UserMessage(content: content);

  factory Message.assistant(String content) => AssistantMessage(content: content);

  factory Message.toolCall(String content) => ToolCallMessage(content: content);

  factory Message.toolResult(String? id, String content) => ToolResultMessage(id: id, content: content);

  @override
  String toString() {
    return 'Message(type: $type, content: $content)';
  }
}

class UserMessage extends Message {
  UserMessage({required super.content}) : super(type: MessageType.user);
}

class AssistantMessage extends Message {
  final String? tools;

  AssistantMessage({required super.content, this.tools}) : super(type: MessageType.assistant);
}

class ToolCallMessage extends Message {
  ToolCallMessage({required super.content}) : super(type: MessageType.toolCall);
}

class ToolResultMessage extends Message {
  ToolResultMessage({required super.id, required super.content}) : super(type: MessageType.toolResult);
}

enum MessageType {
  user,
  assistant,
  toolCall,
  toolResult;

  String toRole() {
    switch (this) {
      case MessageType.user:
        return 'user';
      case MessageType.assistant:
        return 'assistant';
      case MessageType.toolCall:
        return 'assistant';
      case MessageType.toolResult:
        return 'tool';
    }
  }
}
