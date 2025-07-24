import 'dart:convert';
import 'dart:io';
import 'package:ai_clients/clients/ai_client.dart';
import 'package:ai_clients/models.dart';
import 'package:ai_clients/utils.dart';
import 'package:dio/dio.dart';

class BasetenClient extends AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;

  BasetenClient({String? apiUrl, String? apiKey, String? model, super.delay})
    : _dio = Dio(),
      _model = model ?? 'meta-llama/Llama-4-Maverick-17B-128E-Instruct',
      _apiUrl = apiUrl ?? 'https://inference.baseten.co/v1',
      _apiKey = apiKey ?? Platform.environment['BASETEN_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('BASETEN_API_KEY not found in environment variables.');
    }
    _dio.options.baseUrl = _apiUrl;
    _dio.options.headers['Authorization'] = 'Api-Key $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  @override
  Future<String> simpleQuery({
    String? model,
    List<Message> history = const [],
    Duration? delay,
    required String prompt,
    String? system,
    String role = 'user',
    List<Context>? contexts,
  }) async {
    await Future.delayed(delay ?? this.delay ?? const Duration(milliseconds: 300));
    final contextMessage = buildPrompt(prompt: prompt, contexts: contexts);
    final data = {
      'model': model ?? _model,
      "stop": [],
      //"stream": true,
      //"stream_options": {"include_usage": true, "continuous_usage_stats": true},
      "top_p": 1,
      "max_tokens": 1000,
      "temperature": 1,
      "presence_penalty": 1,
      "frequency_penalty": 1,
      'messages': [
        if (system != null) {'role': 'system', 'content': system},
        ...history.map((message) => {'role': message.type, 'content': message.content}),
        {'role': 'user', 'content': prompt + contextMessage},
      ],
    };

    try {
      final response = await _dio.post('/chat/completions', data: data);
      final choices = response.data['choices'];
      if (choices != null && choices.isNotEmpty) {
        return choices[0]['message']['content'] as String;
      } else {
        throw Exception('No response from ChatGPT API.');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<AiClientResponse> query({
    required Message message,
    List<Message> history = const [],
    String? system,
    String? model,
    Duration? delay,
    List<Context>? contexts,
    List<Tool>? tools,
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

    print(data);
    print('');

    try {
      final response = await _dio.post('/chat/completions', data: data);
      return _parseResponse(response.data, originalTools: tools ?? []);
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: [${e.response?.statusCode}] ${e.response?.data ?? e.message}');
    }
  }

  List _removeDuplicityTools(List toolCalls) {
    List<Map<String, dynamic>> uniqueList = [];
    Set<String> seenFunctionNames = {};

    for (var item in toolCalls) {
      String functionName = item['function']['name'];
      if (!seenFunctionNames.contains(functionName)) {
        seenFunctionNames.add(functionName);
        uniqueList.add(item);
      }
    }
    return uniqueList;
  }

  @override
  Future<List<ToolResultMessage>> makeToolCalls({required List<Tool> tools, required List toolCalls}) async {
    final List<ToolResultMessage> toolCallResults = [];
    toolCalls = _removeDuplicityTools(toolCalls);

    for (final toolCall in toolCalls) {
      final function = toolCall['function'];
      final arguments = function['arguments'] is String ? jsonDecode(function['arguments']) : function['arguments'];
      final tool = tools.firstWhere((tool) => tool.name == function['name']);

      final value = await tool.call(arguments);
      toolCallResults.add(ToolResultMessage(id: toolCall['id'], content: value));
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
          'tool_call_id': message.id,
          if (message.type == MessageType.toolCall)
            'tool_calls': jsonDecode(message.content)
          else
            'content': message.content,
        },
      ),
      {
        'role': message.type.toRole(),
        'tool_call_id': message.id,
        'content': buildPrompt(prompt: message.content, contexts: contexts),
      },
    ];

    final data = {
      'model': model,
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
