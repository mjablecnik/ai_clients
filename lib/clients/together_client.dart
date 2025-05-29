import 'dart:io';
import 'package:ai_clients/clients/ai_client.dart';
import 'package:dio/dio.dart';

class TogetherClient implements AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;

  TogetherClient({String? apiUrl, String? apiKey})
    : _dio = Dio(),
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
  Future<String> query({
    required String prompt,
    String? system,
    String? context,
    String model = 'meta-llama/Llama-3.3-70B-Instruct-Turbo-Free',
  }) async {
    final contextMessage = context != null ? '\n\n======CONTEXT======\n\n$context\n\n=============\n\n' : '';
    final data = {
      'model': model,
      'stop': ['</s>', '[/INST]'],
      'max_tokens': 3000,
      'temperature': 0.7,
      'top_p': 0.7,
      'top_k': 50,
      'repetition_penalty': 1,
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
}
