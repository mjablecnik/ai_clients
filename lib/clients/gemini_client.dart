import 'dart:convert';
import 'dart:io';
import 'package:ai_clients/ai_clients.dart';
import 'package:dio/dio.dart';

class GeminiClient extends AiClient {
  final Dio _dio;
  final String _apiKey;
  final String _apiUrl;
  final String _model;

  GeminiClient({String? apiUrl, String? apiKey, String? model, super.delay})
    : _dio = Dio(),
      _model = model ?? 'gemini-2.0-flash',
      _apiUrl = apiUrl ?? 'https://generativelanguage.googleapis.com/v1beta',
      _apiKey = apiKey ?? Platform.environment['GEMINI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables.');
    }
    _dio.options.baseUrl = _apiUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['X-goog-api-key'] = _apiKey;
  }

  @override
  Future<AiClientResponse> query({
    String? model,
    Duration? delay,
    List<Message> history = const [],
    required String prompt,
    String? system,
    List<Context>? contexts,
    List<Tool> tools = const [],
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
      final modelPath = model ?? _model;
      final response = await _dio.post('/models/$modelPath:generateContent', data: data);
      return _parseResponse(response.data, originalTools: tools);
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
    final contents = <Map<String, dynamic>>[];

    // Add system message if provided
    if (system != null) {
      contents.add({
        'role': 'model',
        'parts': [{'text': system}]
      });
    }

    // Add history messages
    for (final message in history) {
      contents.add({
        'role': _mapRole(message.type),
        'parts': [{'text': message.content}]
      });
    }

    // Add current prompt with contexts
    contents.add({
      'role': _mapRole(role),
      'parts': [{'text': buildPrompt(prompt: prompt, contexts: contexts)}]
    });

    final data = {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'topP': 0.95,
        'topK': 40,
        'maxOutputTokens': 2048,
      },
    };

    // Add tools if provided
    if (tools != null && tools.isNotEmpty) {
      data['tools'] = [
        {
          'functionDeclarations': tools.map((tool) => _buildToolObject(tool)).toList(),
        }
      ];
    }

    return data;
  }

  Map<String, dynamic> _buildToolObject(Tool tool) {
    return {
      'name': tool.name,
      'description': tool.description,
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          for (final param in tool.parameters)
            param.name: {
              'type': _mapParamType(param.type),
              'description': param.description,
              if (param.enumValues != null) 'enum': param.enumValues,
            },
        },
        'required': [
          for (final param in tool.parameters)
            if (param.required) param.name,
        ],
      },
    };
  }

  String _mapParamType(String type) {
    // Map JSON Schema types to Gemini API types
    switch (type.toLowerCase()) {
      case 'string':
        return 'STRING';
      case 'number':
        return 'NUMBER';
      case 'integer':
        return 'INTEGER';
      case 'boolean':
        return 'BOOLEAN';
      case 'array':
        return 'ARRAY';
      case 'object':
        return 'OBJECT';
      default:
        return 'STRING';
    }
  }

  String _mapRole(String role) {
    // Map roles to Gemini API roles
    switch (role) {
      case 'user':
        return 'user';
      case 'assistant':
        return 'model';
      case 'system':
        return 'model';
      case 'tool':
        return 'user';
      default:
        return 'user';
    }
  }

  AiClientResponse _parseResponse(Map<String, dynamic> json, {required List<Tool> originalTools}) {
    if (json['candidates'] != null && json['candidates'].isNotEmpty) {
      final candidate = json['candidates'][0];
      final content = candidate['content'];
      
      if (content == null) {
        throw Exception('No content in response from Gemini API.');
      }

      final id = json['promptFeedback']?['requestId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final parts = content['parts'] ?? [];
      String message = '';
      
      // Extract text from parts
      if (parts.isNotEmpty) {
        for (var part in parts) {
          if (part['text'] != null) {
            message += part['text'];
          }
        }
      }

      // Check for function calls
      List<Tool> tools = [];
      if (content['parts'] != null && content['parts'].isNotEmpty) {
        for (var part in content['parts']) {
          if (part['functionCall'] != null) {
            final functionCall = part['functionCall'];
            final name = functionCall['name'];
            final tool = originalTools.firstWhere((tool) => tool.name == name, 
                orElse: () => throw Exception('Tool not found: $name'));
            
            // Parse arguments
            final args = functionCall['args'] ?? {};
            tool.arguments = args;
            tools.add(tool);
          }
        }
      }

      // Determine response type
      if (tools.isNotEmpty) {
        return ToolResponse(
          id: id, 
          tools: tools, 
          rawMessage: jsonEncode(content['parts'])
        );
      } else {
        return AssistantResponse(id: id, message: message);
      }
    } else {
      throw Exception('No response from Gemini API.');
    }
  }
}