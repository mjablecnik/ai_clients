import 'dart:io';
import 'package:ai_clients/clients/ai_client.dart';
import 'package:ai_clients/models.dart';
import 'package:ai_clients/models/message.dart';
import 'package:ai_clients/utils.dart';
import 'package:dio/dio.dart';

typedef HistoryChat = List<Map<String, dynamic>>;

class OpenAiClient implements AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;

  OpenAiClient({String? apiUrl, String? apiKey, String? model})
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

  /// Sends a prompt to the ChatGPT API and returns the response text.
  /// [prompt] is the user's message.
  /// [model] defaults to 'gpt-3.5-turbo'.
  @override
  Future<String> simpleQuery({
    required String prompt,
    String? system,
    List<Context>? contexts,
    String? model,
    String role = 'user',
    Duration delay = Duration.zero,
  }) async {
    await Future.delayed(delay);

    final data = {
      'model': model ?? _model,
      'messages': [
        if (system != null) {'role': 'developer', 'content': system},
        {'role': role, 'content': buildPrompt(prompt: prompt, contexts: contexts)},
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
    required String prompt,
    List<Message> history = const [],
    String? system,
    String? model,
    Duration delay = Duration.zero,
    List<Context>? contexts,
    List<Tool>? tools,
    String role = 'user',
  }) async {
    await Future.delayed(delay);

    final messages = [
      if (system != null) {'role': 'system', 'content': system},
      {'role': role, 'content': buildPrompt(prompt: prompt, contexts: contexts)},
    ];

    final data = {
      'model': model ?? _model,
      'messages': messages,
      if (tools != null && tools.isNotEmpty)
        'tools': tools
            .map(
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
            )
            .toList(),
    };

    try {
      final response = await _dio.post('/chat/completions', data: data);
      //print(response.data);
      return AiClientResponse.fromOpenAi(response.data, originalTools: tools ?? []);
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: [${e.response?.statusCode}] ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<AiClientResponse> chat({
    required String prompt,
    String? system,
    String? model,
    String role = 'user',
    Duration delay = Duration.zero,
    List<Context>? contexts,
    List<Tool>? tools,
    String historyKey = 'default',
  }) {
    // TODO: implement chat
    throw UnimplementedError();
  }
}
