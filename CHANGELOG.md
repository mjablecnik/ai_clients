## 0.8.0

- Added history messages into constructor for AiAgent
- Fixed null function call in GeminiClient


## 0.7.0

- Added comprehensive logging system with configurable outputs
- Implemented Logger class with different log levels (debug, info, warning, error)
- Added support for both console and file logging
- Integrated logging into AiClient and AiAgent classes
- Added tool call logging
- Added extensible LogHandler interface for future remote logging support

## 0.6.0

- Added EvaluationAgent for assessing AI response quality.
- Added GeminiClient for Google's Gemini API integration.
- Reorganized exports.
- Added support for MCP client.
- Fixed tool calling with arguments.
- Added Message object into query method of all AI clients.
- Added implementation of Baseten client.

## 0.5.0

- Removed chat method from AI clients.
- Added configurable delay for AI clients.
- Refactored code.

## 0.4.0

- Added AiAgent class to interact with AI clients
- Implemented tool calling capabilities in AI agent
- Added chat history support
- Made model parameter optional with fallback to class model
- Renamed 'query' method to 'chat' and added new 'chat' method with history support
- Simplified TogetherClient chat API
- Simplified models exports and removed unused token-related models
- Restructured AiAgent file and exports

## 0.3.1

- Simplified the prompt building process.
  
## 0.3.0

- Added more contexts into one prompt.
- Added duration into queries.
  
## 0.2.0

- Added class for instantiating AI clients.

## 0.1.0

- Initial version.
- Updated README.md to reflect correct usage and purpose of the package.
- Updated example code in example/ai_clients_example.dart to demonstrate correct usage.
- Updated description in pubspec.yaml to better reflect the package's purpose.
