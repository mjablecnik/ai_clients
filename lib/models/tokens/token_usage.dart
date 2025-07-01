import 'package:ai_clients/models/tokens/prompt_tokens_details.dart';
import 'package:ai_clients/models/tokens/token_details.dart';

class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final PromptTokensDetails promptTokensDetails;
  final TokenDetails completionTokensDetails;

  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.promptTokensDetails,
    required this.completionTokensDetails,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
      promptTokensDetails:
      PromptTokensDetails.fromJson(json['prompt_tokens_details']),
      completionTokensDetails:
      TokenDetails.fromJson(json['completion_tokens_details']),
    );
  }

  Map<String, dynamic> toJson() => {
    'prompt_tokens': promptTokens,
    'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
    'prompt_tokens_details': promptTokensDetails.toJson(),
    'completion_tokens_details': completionTokensDetails.toJson(),
  };
}
