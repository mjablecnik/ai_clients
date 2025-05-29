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
  ai_clients: ^0.1.0
```

Then run:

```sh
dart pub get
```

---

## Usage

Import the package and create an instance of the desired client. Each client requires an API key, which can be provided as a constructor argument or via environment variable.

### Example: Baseten

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  var client = AiClients.baseten(); // Uses BASETEN_API_KEY from env by default
  var response = await client.query(prompt: 'Hello, how are you?');
  print(response);
}
```

### Example: Together

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  var client = AiClients.together(); // Uses TOGETHER_API_KEY from env by default
  var response = await client.query(prompt: 'Hello, how are you?');
  print(response);
}
```

### Example: OpenAI

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  var client = AiClients.openAi(apiKey: 'YOUR_OPENAI_API_KEY');
  var response = await client.query(
    prompt: 'Hello, how are you?',
    model: 'gpt-4.1', // Optional, defaults to 'gpt-4.1'
  );
  print(response);
}
```

---

## API Reference

All clients implement the following interface:

```dart
Future<String> query({
  required String prompt,
  String? system,   // Optional system message (role)
  String? context,  // Optional context to append
  String model,     // Model name (default varies by client)
});
```

- **prompt**: The user message to send to the model.
- **system**: (Optional) System or developer message for context/instructions.
- **context**: (Optional) Additional context appended to the prompt.
- **model**: (Optional) Model name. Each client has a sensible default.

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


