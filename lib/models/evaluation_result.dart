class EvaluationResult {
  final int score;
  final String reason;

  const EvaluationResult({required this.score, required this.reason});

  @override
  String toString() {
    return 'VerificationResult:\n  - score: $score \n  - reason: "$reason"\n';
  }

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      score: json['score'] as int,
      reason: json['reason'] as String,
    );
  }
}
