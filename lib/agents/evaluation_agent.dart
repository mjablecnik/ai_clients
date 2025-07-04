import 'dart:convert';

import 'package:ai_clients/ai_clients.dart';
import 'package:ai_clients/models/evaluation_result.dart';

class EvaluationAgent {
  const EvaluationAgent({required this.client});

  final AiClient client;

  final evaluationPrompt = """
You are a verification AI agent. Your task is to evaluate the accuracy, relevance, and completeness of an answer in relation to a given question.
Evaluate only the factual and logical quality of the answer — ignore style, tone, or grammar.

Return your evaluation as a JSON object in the following format:
```
{
  "score": int,         // A number from 1 to 5
  "reason": string      // A brief explanation of why this score was given
}
```

Use the following rating scale:
1 – Completely incorrect or entirely irrelevant.
2 – Mostly incorrect or only loosely related.
3 – Partially correct but with significant issues or missing key information.
4 – Mostly correct and relevant, with minor flaws.
5 – Fully correct, accurate, and completely answers the question.

Be concise but clear in the explanation. The JSON must be valid and include only the score and reason fields.
  """;

  Future<EvaluationResult> evaluate({String? prompt, required String question, required String answer, int attempts = 3}) async {
    final response = await client.simpleQuery(
      prompt: prompt ?? evaluationPrompt,
      contexts: [
        Context(name: 'question', value: question),
        Context(name: 'answer', value: answer),
      ],
    );

    final result = convertToVerificationResult(response);

    if (result == null) {
      if (--attempts == 0) throw Exception('Failed to verify answer');
      print("Remain attempts: $attempts");
      return evaluate(question: question, answer: answer, attempts: attempts);
    } else {
      return result;
    }
  }

  EvaluationResult? convertToVerificationResult(String data) {
    try {
      final cleanedData = data.replaceAll('```json', '').replaceAll('```', '');
      final map = jsonDecode(cleanedData);
      return EvaluationResult.fromJson(map);
    } catch (e) {
      return null;
    }
  }
}
