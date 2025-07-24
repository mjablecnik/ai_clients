import 'dart:convert';
import 'dart:io';
import 'package:ai_clients/ai_clients.dart';
import 'package:dio/dio.dart';

class TogetherClient extends AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;
  final Map<String, HistoryChat> _history = {};

  Map<String, HistoryChat> get history => _history;

  TogetherClient({String? apiUrl, String? apiKey, String? model, super.delay})
    : _dio = Dio(),
      _model = model ?? 'meta-llama/Llama-3.3-70B-Instruct-Turbo-Free',
      _apiUrl = apiUrl ?? 'https://api.together.xyz/v1',
      _apiKey = apiKey ?? Platform.environment['TOGETHER_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('TOGETHER_API_KEY not found in environment variables.');
    }
    _dio.options.baseUrl = _apiUrl;
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  @override
  Future<AiClientResponse> query({
    String? model,
    Duration? delay,
    List<Message> history = const [],
    required Message message,
    String? system,
    List<Context>? contexts,
    List<Tool> tools = const [],
  }) async {
    await Future.delayed(delay ?? this.delay ?? const Duration(milliseconds: 300));

    final data = _buildDataObject(
      model: model ?? _model,
      tools: tools,
      system: system,
      contexts: contexts,
      history: history,
      message: message,
    );

    try {
      final response = await _dio.post('/chat/completions', data: data);
      return _parseResponse(response.data, originalTools: tools);
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: [${e.response?.statusCode}] ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<ToolResultMessage>> makeToolCalls({required List<Tool> tools, required List toolCalls}) async {
    final List<ToolResultMessage> toolCallResults = [];
    for (final toolCall in toolCalls) {
      final function = toolCall['function'];
      final arguments = function['arguments'] is String ? jsonDecode(function['arguments']) : function['arguments'];
      final tool = tools.firstWhere((tool) => tool.name == function['name']);

      final value = await tool.call(arguments);

      toolCallResults.add(
        ToolResultMessage(
          id: toolCall['id'],
          content: buildPrompt(
            prompt: '',
            contexts: [Context(name: tool.name, value: value)],
          ),
        ),
      );
    }
    return toolCallResults;
  }

  Map<String, dynamic> _buildDataObject({
    List<Tool>? tools,
    String? system,
    List<Context>? contexts,
    List<Message> history = const [],
    required String model,
    required Message message,
  }) {
    final messages = [
      if (system != null) {'role': 'system', 'content': system},
      ...history.map(
        (message) => {
          'role': message.type.toRole(),
          'content': message.content,
        },
      ),
      {
        'role': message.type.toRole(),
        'content': buildPrompt(prompt: message.content, contexts: contexts),
      },
    ];

    final data = {
      'model': model,
      'stop': ['</s>', '[/INST]'],
      'max_tokens': 3000,
      'temperature': 0.7,
      'top_p': 0.7,
      'top_k': 50,
      'repetition_penalty': 1,
      'messages': messages,
      if (tools != null && tools.isNotEmpty) 'tools': _buildToolsObject(tools),
    };
    return data;
  }

  List<Map<String, dynamic>> _buildToolsObject(List<Tool> tools) {
    return [
      ...tools.map(
        (tool) => {
          'type': 'function',
          'function': {
            'name': tool.name,
            'description': tool.description,
            'parameters': {
              'type': 'object',
              'properties': {
                for (final param in tool.parameters)
                  param.name: {
                    'type': param.type,
                    'description': param.description,
                    if (param.enumValues != null) 'enum': param.enumValues,
                  },
              },
              'required': [
                for (final param in tool.parameters)
                  if (param.required) param.name,
              ],
            },
          },
        },
      ),
    ];
  }

  AiClientResponse _parseResponse(Map<String, dynamic> json, {required List<Tool> originalTools}) {
    final choices = json['choices'];
    if (choices != null && choices.isNotEmpty) {
      final choice = choices[0];
      final messageObj = choice['message'] ?? {};
      final id = json['id'] ?? '';
      final role = messageObj['role'] ?? 'assistant';
      final message = messageObj['content'] ?? '';

      // Parse tools if present in the message
      List<Tool> tools = [];
      if (messageObj['tool_calls'] != null && messageObj['tool_calls'] is List) {
        for (var t in (messageObj['tool_calls'] as List)) {
          final name = (t as Map<String, dynamic>)['function']['name'];
          final tool = originalTools.firstWhere((tool) => tool.name == name);
          //tool.arguments = jsonDecode(t['function']['arguments']);
          tools.add(tool);
        }
      }

      final finishReason = choices[0]['finish_reason'];

      if (finishReason == 'tool_calls') {
        return ToolResponse(id: id, tools: tools, rawMessage: jsonEncode(messageObj['tool_calls']));
      } else if (finishReason == 'stop') {
        return AssistantResponse(id: id, message: message);
      } else {
        throw Exception('Unknown response role: $role.');
      }
    } else {
      throw Exception('No response from ChatGPT API.');
    }
  }
}
