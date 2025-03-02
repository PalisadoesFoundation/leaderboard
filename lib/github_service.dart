import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class GithubService {
  final String baseUrl = 'https://api.github.com';
  final authToken = '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';
  final owner = 'PalisadoesFoundation';

  Future<Map<String, int>> getMergedPRs(String repo,
      {DateTime? startDate, DateTime? endDate}) async {
    Map<String, int> userPrCounts = {};
    int page = 1;
    bool hasMore = true;

    final now = DateTime.now();
    startDate ??= DateTime(now.year, now.month, 1);
    endDate ??= DateTime(now.year, now.month, 0);

    try {
      while (hasMore) {
        final url =
            Uri.parse('$baseUrl/repos/$owner/$repo/pulls?state=closed&page=$page&per_page=100');

        final response = await http.get(url, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': authToken,
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);

          if (data.isEmpty) {
            hasMore = false;
          } else {
            bool foundOlderPR = false;

            for (var pr in data) {
              if (pr['merged_at'] != null) {
                final mergedAt = DateTime.parse(pr['merged_at']);
                if (mergedAt.isAfter(startDate) &&
                    mergedAt.isBefore(endDate.add(const Duration(days: 1)))) {
                  final user = pr['user']['login'];
                  userPrCounts[user] = (userPrCounts[user] ?? 0) + 1;
                } else if (mergedAt.isBefore(startDate)) {
                  foundOlderPR = true;
                }
              }
            }

            if (foundOlderPR) {
              hasMore = false;
            } else {
              page++;
            }
          }
        } else {
          throw Exception('Failed to fetch PRs for $repo: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      log('Error fetching PRs: $e');
    }

    return userPrCounts;
  }

  Future<Map<String, int>> getReviewedPRs(String repo) async {
    Map<String, int> userReviewCounts = {};
    int page = 1;
    bool hasMore = true;

    try {
      while (hasMore) {
        final url = Uri.parse('$baseUrl/repos/$owner/$repo/pulls/comments?page=$page&per_page=100');

        final response = await http.get(url, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': authToken,
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isEmpty) {
            hasMore = false;
          } else {
            for (var review in data) {
              final user = review['user']['login'];
              userReviewCounts[user] = (userReviewCounts[user] ?? 0) + 1;
            }
            page++;
          }
        } else {
          throw Exception('Failed to fetch PR reviews: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Error fetching PR reviews: $e');
    }

    return userReviewCounts;
  }

  Future<Map<String, int>> getCreatedIssues(String repo) async {
    Map<String, int> userIssueCounts = {};
    int page = 1;
    bool hasMore = true;

    try {
      while (hasMore) {
        final url = Uri.parse('$baseUrl/repos/$owner/$repo/issues?page=$page&per_page=100');

        final response = await http.get(url, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': authToken,
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isEmpty) {
            hasMore = false;
          } else {
            for (var issue in data) {
              final user = issue['user']['login'];
              userIssueCounts[user] = (userIssueCounts[user] ?? 0) + 1;
            }
            page++;
          }
        } else {
          throw Exception('Failed to fetch issues: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Error fetching issues: $e');
    }

    return userIssueCounts;
  }

  Future<Map<String, int>> getCommits(String repo) async {
    Map<String, int> userCommitCounts = {};
    int page = 1;
    bool hasMore = true;

    try {
      while (hasMore) {
        final url = Uri.parse('$baseUrl/repos/$owner/$repo/commits?page=$page&per_page=100');

        final response = await http.get(url, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization': authToken,
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isEmpty) {
            hasMore = false;
          } else {
            for (var commit in data) {
              final user = commit['commit']['author']['name'];
              userCommitCounts[user] = (userCommitCounts[user] ?? 0) + 1;
            }
            page++;
          }
        } else {
          throw Exception('Failed to fetch commits: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Error fetching commits: $e');
    }

    return userCommitCounts;
  }
}
