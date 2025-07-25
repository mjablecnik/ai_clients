# AI Clients Package

[![pub package](https://img.shields.io/pub/v/ai_clients.svg)](https://pub.dev/packages/ai_clients)

A Dart package providing a unified interface for interacting with various AI models (OpenAI, Baseten, Together, Gemini) through simple, consistent clients.

---

## Features

- Unified interface for multiple AI providers (OpenAI, Baseten, Together, Gemini)
- Simple, async API for chat/completion models
- Easy integration with your Dart or Flutter projects
- Supports custom API endpoints and models
- Extensible: add your own AI client by implementing the interface
- Tool calling support for AI agents
- Evaluation capabilities for assessing AI response quality
- MCP (Model Context Protocol) client support
- Comprehensive logging system with configurable outputs

---

## Getting Started

### Installation

Add `ai_clients` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  ai_clients: ^0.6.0
```

Then run:

```sh
dart pub get
```

---

## Usage

Import the package and create an instance of the desired client. Each client requires an API key, which can be provided as a constructor argument or via environment variable.

### Using AiClient

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  // Create a client
  var client = AiClients.together(); // Uses TOGETHER_API_KEY from env by default
  
  // Simple query with the model
  var response = await client.simpleQuery(
    system: 'You are a helpful assistant',
    prompt: 'Hello, how are you?',
  );
  
  print(response);
  
  // Using the query method with Message object
  var detailedResponse = await client.query(
    system: 'You are a helpful assistant',
    message: Message.user('Hello, how are you?'),
  );
  
  print(detailedResponse.message);
}
```

### Using AiAgent

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  // Create an AI client
  var client = AiClients.together();
  
  // Create an agent with tools
  var agent = AiAgent(
    client: client,
    description: 'You are a helpful assistant',
    tools: [
      Tool(
        name: 'getWeatherInformation',
        description: 'Gets weather information',
        function: getWeatherInformation,
      ),
    ],
  );
  
  // Send a message to the agent
  var response = await agent.sendMessage(
    Message.user('What is the weather like today?'),
  );
  
  // The agent automatically handles tool calls
  print(response.content);
}
```

### Using EvaluationAgent

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  // Create an AI client
  var client = AiClients.openAi();
  
  // Create an evaluation agent
  var evaluator = EvaluationAgent(client: client);
  
  // Evaluate an AI response
  var result = await evaluator.evaluate(
    question: 'What is the capital of France?',
    answer: 'The capital of France is Paris.',
  );
  
  // Print the evaluation result
  print('Score: ${result.score}/5');
  print('Reason: ${result.reason}');
}
```

### Using AiMcpClient

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  // Create an MCP client
  var mcpClient = AiMcpClient(
    name: 'My MCP Client',
    version: '1.0.0',
  );
  
  // Connect to an MCP server
  await mcpClient.sse(url: Uri.parse('http://localhost:8000/mcp'));
  
  // Get available tools from the MCP server
  var tools = await mcpClient.getTools();
  
  // Create an agent with MCP tools
  var client = AiClients.openAi();
  var agent = AiAgent(
    client: client,
    description: 'You are a helpful assistant',
    tools: tools,
  );
  
  // Use the agent with MCP tools
  var response = await agent.sendMessage(
    Message.user('Help me with a task using MCP tools'),
  );
  
  print(response.content);
}
```

### Using the Logging System

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  final logger = Logger(
    config: LogConfig(
      enabled: true,
      globalLevel: LogLevel.debug,
      enableFileOutput: true,
      enableConsoleOutput: false,
      logFilePath: "/tmp/logs/test.log",
    ),
  );

  final client = AiClients.gemini(
    logger: logger,
  );

  var response = await client.simpleQuery(
    system: 'You are a helpful assistant',
    prompt: 'Hello, how are you?',
  );

  print(response);
}
```

See the [logging example](example/logging_example.dart) for more detailed usage.

---

## API Reference

### AiClient Interface

All clients implement the following interface:

```dart
// Simple query that returns just a string response
Future<String> simpleQuery({
  String? model,
  List<Message> history = const [],
  Duration? delay,
  required String prompt,
  String? system,
  String role = 'user',
  List<Context>? contexts,
});

// Query with more detailed response
Future<AiClientResponse> query({
  required Message message,
  List<Message> history = const [],
  String? system,
  String? model,
  Duration? delay,
  List<Context>? contexts,
  List<Tool> tools = const [],
});
```

- **prompt**: The user message to send to the model (for simpleQuery).
- **message**: The Message object to send to the model (for query).
- **system**: (Optional) System or developer message for context/instructions.
- **contexts**: (Optional) Additional context to provide to the model.
- **model**: (Optional) Model name. Each client has a sensible default.
- **role**: (Optional) Role of the message sender (default: 'user').
- **delay**: (Optional) Delay before sending the request.
- **tools**: (Optional) List of tools the model can use.
- **history**: (Optional) List of previous messages for conversation context.

### AiAgent Class

The AiAgent class provides a higher-level interface for interacting with AI models:

```dart
AiAgent({
  required AiClient client,
  required String description,
  List<Tool> tools = const [],
});

Future<Message> sendMessage(
  Message message,
  {List<Context> context = const []}
);
```

- **client**: The AI client to use for queries.
- **description**: System message describing the agent's role.
- **tools**: List of tools the agent can use.
- **message**: Message to send to the agent.
- **context**: Additional context to provide to the agent.

### EvaluationAgent Class

The EvaluationAgent class provides functionality for evaluating AI responses:

```dart
EvaluationAgent({
  required AiClient client,
});

Future<EvaluationResult> evaluate({
  String? prompt,
  required String question,
  required String answer,
  int attempts = 3,
});
```

- **client**: The AI client to use for evaluation.
- **prompt**: (Optional) Custom evaluation prompt.
- **question**: The original question.
- **answer**: The AI response to evaluate.
- **attempts**: Number of retry attempts if evaluation fails.

### AiMcpClient Class

The AiMcpClient class provides integration with the Model Context Protocol:

```dart
AiMcpClient({
  String name = 'Example Client',
  String version = '1.0.0',
  bool enableDebugLogging = true,
});

Future<dynamic> sse({
  required Uri url,
});

Future<List<Tool>> getTools();
```

- **name**: Name of the MCP client.
- **version**: Version of the MCP client.
- **enableDebugLogging**: Whether to enable debug logging.
- **url**: URL of the MCP server.

### Logger Class

The Logger class provides a centralized logging system:

```dart
// Get the singleton logger instance
Logger({LogConfig? config});

// Update the logger configuration
void updateConfig(LogConfig newConfig);

// Log methods
void debug(String message, {String? source, Map<String, dynamic>? metadata});
void info(String message, {String? source, Map<String, dynamic>? metadata});
void warning(String message, {String? source, Map<String, dynamic>? metadata});
void error(String message, {String? source, Map<String, dynamic>? metadata});

// Component-specific logging
void clientLog(LogLevel level, String message, {String? clientName, Map<String, dynamic>? metadata});
void agentLog(LogLevel level, String message, {String? agentName, Map<String, dynamic>? metadata});
void toolLog(LogLevel level, String message, {String? toolName, Map<String, dynamic>? metadata});
```

### LogConfig Class

The LogConfig class controls logging behavior:

```dart
LogConfig({
  bool enabled = false,
  LogLevel globalLevel = LogLevel.info,
  bool enableClientLogs = true,
  bool enableAgentLogs = true,
  bool enableToolLogs = true,
  bool enableConsoleOutput = true,
  bool enableFileOutput = false,
  String? logFilePath,
});

// Factory constructors
factory LogConfig.disabled();
factory LogConfig.consoleOnly({LogLevel level = LogLevel.info, ...});
factory LogConfig.fileOnly({required String filePath, LogLevel level = LogLevel.info, ...});
factory LogConfig.both({required String filePath, LogLevel level = LogLevel.info, ...});
```

### API Key Environment Variables

- **BasetenClient**: `BASETEN_API_KEY`
- **GeminiClient**: `GEMINI_API_KEY`
- **OpenAiClient**: `OPENAI_API_KEY`
- **TogetherClient**: `TOGETHER_API_KEY`

You can also pass the API key directly to the client constructor.

---

## Available Clients

- `BasetenClient` (default model: `meta-llama/Llama-4-Maverick-17B-128E-Instruct`)
- `GeminiClient` (default model: `gemini-2.0-flash`)
- `OpenAiClient` (default model: `gpt-4.1`)
- `TogetherClient` (default model: `meta-llama/Llama-3.3-70B-Instruct-Turbo-Free`)

Each client can be instantiated directly or through the `AiClients` factory class.

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## Author

👤 **Martin Jablečník**

- Website: [martin-jablecnik.cz](https://www.martin-jablecnik.cz)
- Github: [@mjablecnik](https://github.com/mjablecnik)
- Blog: [dev.to/mjablecnik](https://dev.to/mjablecnik)

---

## Show your support

Give a ⭐️ if this project helped you!

<a href="https://www.patreon.com/mjablecnik">
  <img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>

---

## 📝 License

Copyright © 2025 [Martin Jablečník](https://github.com/mjablecnik).
This project is [MIT License](./LICENSE) licensed.
