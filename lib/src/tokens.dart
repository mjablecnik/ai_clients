class TokenDetails {
  final int reasoningTokens;
  final int audioTokens;
  final int acceptedPredictionTokens;
  final int rejectedPredictionTokens;

  const TokenDetails({
    required this.reasoningTokens,
    required this.audioTokens,
    required this.acceptedPredictionTokens,
    required this.rejectedPredictionTokens,
  });

  factory TokenDetails.fromJson(Map<String, dynamic> json) {
    return TokenDetails(
      reasoningTokens: json['reasoning_tokens'] ?? 0,
      audioTokens: json['audio_tokens'] ?? 0,
      acceptedPredictionTokens: json['accepted_prediction_tokens'] ?? 0,
      rejectedPredictionTokens: json['rejected_prediction_tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'reasoning_tokens': reasoningTokens,
    'audio_tokens': audioTokens,
    'accepted_prediction_tokens': acceptedPredictionTokens,
    'rejected_prediction_tokens': rejectedPredictionTokens,
  };
}

class PromptTokensDetails {
  final int cachedTokens;
  final int audioTokens;

  const PromptTokensDetails({
    required this.cachedTokens,
    required this.audioTokens,
  });

  factory PromptTokensDetails.fromJson(Map<String, dynamic> json) {
    return PromptTokensDetails(
      cachedTokens: json['cached_tokens'] ?? 0,
      audioTokens: json['audio_tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'cached_tokens': cachedTokens,
    'audio_tokens': audioTokens,
  };
}

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
