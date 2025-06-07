import 'dart:io';
import 'package:ai_clients/clients/ai_client.dart';
import 'package:ai_clients/src/models.dart';
import 'package:ai_clients/src/utils.dart';
import 'package:dio/dio.dart';

class OpenAiClient implements AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;

  OpenAiClient({String? apiUrl, String? apiKey})
    : _dio = Dio(),
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
  Future<String> query({
    required String prompt,
    String? system,
    List<Context>? contexts,
    String model = 'gpt-4.1',
    Duration delay = Duration.zero,
  }) async {
    await Future.delayed(delay);
    final contextMessage = buildPrompt(prompt: prompt, contexts: contexts);
    final data = {
      'model': model,
      'messages': [
        if (system != null) {'role': 'developer', 'content': system},
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
