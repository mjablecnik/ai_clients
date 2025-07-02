import 'dart:io';
import 'package:ai_clients/ai_clients.dart';
import 'package:dio/dio.dart';

class TogetherClient implements AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;
  final Map<String, HistoryChat> _history = {};

  Map<String, HistoryChat> get history => _history;

  TogetherClient({String? apiUrl, String? apiKey, String? model})
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

  /// Sends a prompt to the Together API and returns the response text.
  /// [prompt] is the user's message.
  /// [model] defaults to 'meta-llama/Llama-3.3-70B-Instruct-Turbo-Free'.
  @override
  Future<String> simpleQuery({
    String? model,
    Duration delay = Duration.zero,
    required String prompt,
    String? system,
    String role = 'user',
    List<Context>? contexts,
    historyKey = 'simpleQueryHistory',
  }) async {
    await Future.delayed(delay);

    final data = {
      'model': model ?? _model,
      'stop': ['</s>', '[/INST]'],
      'max_tokens': 3000,
      'temperature': 0.7,
      'top_p': 0.7,
      'top_k': 50,
      'repetition_penalty': 1,
      'messages': [
        if (system != null) {'role': 'system', 'content': system},
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
    String? model,
    Duration delay = Duration.zero,
    List<Message> history = const [],
    required String prompt,
    String? system,
    List<Context>? contexts,
    List<Tool>? tools,
    String role = 'user',
  }) async {
    await Future.delayed(delay);

    final messages = [
      if (system != null) {'role': 'system', 'content': system},
      ...history.map((message) => {'role': message.type, 'content': message.content}),
      {'role': role, 'content': buildPrompt(prompt: prompt, contexts: contexts)},
    ];

    final data = {
      'model': model ?? _model,
      'stop': ['</s>', '[/INST]'],
      'max_tokens': 3000,
      'temperature': 0.7,
      'top_p': 0.7,
      'top_k': 50,
      'repetition_penalty': 1,
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
                        }
                    },
                    'required': [
                      for (final param in tool.parameters)
                        if (param.required) param.name
                    ],
                  },
                },
              },
            )
            .toList(),
    };

    try {
      final response = await _dio.post('/chat/completions', data: data);
      return AiClientResponse.fromOpenAi(response.data, originalTools: tools ?? []);
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: [${e.response?.statusCode}] ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<AiClientResponse> chat({
    String? model,
    Duration delay = Duration.zero,
    required String prompt,
    String? system,
    List<Context>? contexts,
    List<Tool>? tools,
    String role = 'user',
    historyKey = 'default',
  }) async {
    await Future.delayed(delay);

    if (!_history.containsKey(historyKey)) _history[historyKey] = [];
    if (system != null && _history[historyKey]!.isEmpty) _history[historyKey]!.add({'role': 'system', 'content': system});
    _history[historyKey]!.add({'role': role, 'content': buildPrompt(prompt: prompt, contexts: contexts)});

    final messages = [
      if (system != null) {'role': 'system', 'content': system},
      ..._history[historyKey]!,
    ];

    final data = {
      'model': model ?? _model,
      'stop': ['</s>', '[/INST]'],
      'max_tokens': 3000,
      'temperature': 0.7,
      'top_p': 0.7,
      'top_k': 50,
      'repetition_penalty': 1,
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
                    }
                },
                'required': [
                  for (final param in tool.parameters)
                    if (param.required) param.name
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

      final choices = response.data['choices'];
      print(choices[0]['message']);
      if (choices != null && choices.isNotEmpty && choices[0]['message'] != null) {
        _history[historyKey]!.add({...choices[0]['message']});
      }

      return AiClientResponse.fromOpenAi(response.data, originalTools: tools ?? []);
    } on DioException catch (e) {
      throw Exception('Failed to fetch response: [${e.response?.statusCode}] ${e.response?.data ?? e.message}');
    }
  }
}
