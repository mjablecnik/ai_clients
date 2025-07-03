# AI Clients Package

[![pub package](https://img.shields.io/pub/v/ai_clients.svg)](https://pub.dev/packages/ai_clients)

A Dart package providing a unified interface for interacting with various AI models (OpenAI, Baseten, Together) through simple, consistent clients.

---

## Features

- Unified interface for multiple AI providers (OpenAI, Baseten, Together)
- Simple, async API for chat/completion models
- Easy integration with your Dart or Flutter projects
- Supports custom API endpoints and models
- Extensible: add your own AI client by implementing the interface

---

## Getting Started

### Installation

Add `ai_clients` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  ai_clients: ^0.5.0
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
  
  // Simple chat with the model
  var response = await client.query(
    system: 'You are a helpful assistant',
    prompt: 'Hello, how are you?',
  );
  
  print(response.message);
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

---

## API Reference

### AiClient Interface

All clients implement the following interface:

```dart
// Simple query that returns just a string response
Future<String> simpleQuery({
  required String prompt,
  List<Message> history = const [],
  String? system,
  List<Context>? contexts,
  String model,
  String role = 'user',
  Duration delay = Duration.zero,
});

// Query with more detailed response
Future<AiClientResponse> query({
  required String prompt,
  List<Message> history = const [],
  String? system,
  String model,
  String role = 'user',
  Duration delay = Duration.zero,
  List<Context>? contexts,
  List<Tool>? tools,
});
```

- **prompt**: The user message to send to the model.
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

### API Key Environment Variables

- **BasetenClient**: `BASETEN_API_KEY`
- **OpenAiClient**: `OPENAI_API_KEY`
- **TogetherClient**: `TOGETHER_API_KEY`

You can also pass the API key directly to the client constructor.

---

## Available Clients

- `BasetenClient` (default model: `meta-llama/Llama-4-Maverick-17B-128E-Instruct`)
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


