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

  @override
  String toString() =>
      'TokenDetails(reasoningTokens: \$reasoningTokens, audioTokens: \$audioTokens, acceptedPredictionTokens: \$acceptedPredictionTokens, rejectedPredictionTokens: \$rejectedPredictionTokens)';
}