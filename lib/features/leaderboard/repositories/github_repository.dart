import '../../../core/constants/github_constants.dart';
import '../../../core/models/github_stats.dart';
import '../../../core/services/github_service.dart';

class GithubRepository {
  final GithubService _githubService;

  GithubRepository({required GithubService githubService}) : _githubService = githubService;

  Future<GithubStats> fetchMonthlyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    Map<String, int> aggregatedUserPrCounts = {};
    Map<String, int> aggregatedUserReviewCounts = {};

    try {
      for (String repo in GithubConstants.repositories) {
        final (repoUserPrCounts, repoUserReviewCounts) =
            await _githubService.getMergedPRsAndReviews(
          repo,
          startDate: startDate,
          endDate: endDate,
        );

        repoUserPrCounts.forEach((user, count) {
          aggregatedUserPrCounts[user] = (aggregatedUserPrCounts[user] ?? 0) + count;
        });

        repoUserReviewCounts.forEach((user, count) {
          aggregatedUserReviewCounts[user] = (aggregatedUserReviewCounts[user] ?? 0) + count;
        });
      }

      // Sort user PR counts in descending order
      final sortedUserPrCounts = Map.fromEntries(
        aggregatedUserPrCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      // Sort user Review counts in descending order
      final sortedUserReviewCounts = Map.fromEntries(
        aggregatedUserReviewCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      return GithubStats(
        prCounts: sortedUserPrCounts,
        reviewCounts: sortedUserReviewCounts,
      );
    } catch (e) {
      rethrow;
    }
  }
}
