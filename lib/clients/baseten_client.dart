import 'dart:io';
import 'package:ai_clients/clients/ai_client.dart';
import 'package:ai_clients/models.dart';
import 'package:ai_clients/utils.dart';
import 'package:dio/dio.dart';

class BasetenClient implements AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;

  BasetenClient({String? apiUrl, String? apiKey, String? model})
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

  /// Sends a prompt to the Llama API and returns the response text.
  /// [prompt] is the user's message.
  /// [model] defaults to 'meta-llama/Llama-4-Maverick-17B-128E-Instruct'.
  @override
  Future<String> simpleQuery({
    String? model,
    Duration delay = Duration.zero,
    required String prompt,
    String? system,
    String role = 'user',
    List<Context>? contexts,
  }) async {
    await Future.delayed(delay);
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
    String? model,
    Duration delay = Duration.zero,
    List<Message> history = const [],
    required String prompt,
    String? system,
    String role = 'user',
    List<Context>? contexts,
    List<Tool>? tools,
  }) {
    throw UnimplementedError();
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
