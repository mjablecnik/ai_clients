import 'dart:convert';
import 'dart:io';
import 'package:ai_clients/clients/ai_client.dart';
import 'package:ai_clients/models.dart';
import 'package:ai_clients/utils.dart';
import 'package:dio/dio.dart';

typedef HistoryChat = List<Map<String, dynamic>>;

class OpenAiClient extends AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;

  OpenAiClient({String? apiUrl, String? apiKey, String? model, super.delay})
    : _dio = Dio(),
      _model = model ?? 'gpt-4.1',
      _apiUrl = apiUrl ?? 'https://api.openai.com/v1',
      _apiKey = apiKey ?? Platform.environment['OPENAI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found in environment variables.');
    }
    _dio.options.baseUrl = _apiUrl;
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  @override
  Future<AiClientResponse> query({
    required String prompt,
    List<Message> history = const [],
    String? system,
    String? model,
    Duration? delay,
    List<Context>? contexts,
    List<Tool>? tools,
    String role = 'user',
  }) async {
    await Future.delayed(delay ?? this.delay);

    final data = _buildDataObject(
      model: model ?? _model,
      tools: tools,
      system: system,
      contexts: contexts,
      history: history,
      prompt: prompt,
      role: role,
    );

    try {
      final response = await _dio.post('/chat/completions', data: data);
      return _parseResponse(response.data, originalTools: tools ?? []);
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: [${e.response?.statusCode}] ${e.response?.data ?? e.message}');
    }
  }

  Map<String, dynamic> _buildDataObject({
    List<Tool>? tools,
    String? system,
    List<Context>? contexts,
    List<Message> history = const [],
    required String model,
    required String prompt,
    required String role,
  }) {
    final messages = [
      if (system != null) {'role': 'system', 'content': system},
      ...history.map((message) => {'role': message.type, 'content': message.content}),
      {'role': role, 'content': buildPrompt(prompt: prompt, contexts: contexts)},
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
          tool.arguments = jsonDecode(t['function']['arguments']);
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
