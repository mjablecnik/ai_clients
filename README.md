# AI Clients Package

This Dart package provides a unified interface for interacting with various AI models through different clients.

## Usage

To use this package, import the `ai_clients.dart` library and create an instance of one of the available AI clients (e.g., BasetenClient, OpenAIClient, TogetherClient).

```dart
import 'package:ai_clients/ai_clients.dart';

void main() async {
  var client = OpenAIClient(apiKey: 'YOUR_API_KEY');
  var response = await client.query(prompt: 'Hello, how are you?');
  print(response);
}
```

## Available Clients

* BasetenClient
* OpenAIClient
* TogetherClient

## Features

* Unified interface for different AI models
* Easy integration with various AI APIs

## Installation

Add `ai_clients` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  ai_clients: ^0.1.0
```

Then, run `dart pub get` to install the package.
