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

  @override
  String toString() =>
      'PromptTokensDetails(cachedTokens: \$cachedTokens, audioTokens: \$audioTokens)';
}