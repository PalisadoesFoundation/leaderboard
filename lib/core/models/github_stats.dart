class GithubStats {
  final Map<String, int> prCounts;
  final Map<String, int> reviewCounts;

  const GithubStats({
    required this.prCounts,
    required this.reviewCounts,
  });

  GithubStats copyWith({
    Map<String, int>? prCounts,
    Map<String, int>? reviewCounts,
  }) {
    return GithubStats(
      prCounts: prCounts ?? this.prCounts,
      reviewCounts: reviewCounts ?? this.reviewCounts,
    );
  }
}
