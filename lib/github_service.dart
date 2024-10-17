import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class GithubService {
  final String baseUrl = 'https://api.github.com';

  Future<Map<String, int>> getMergedPRs(String owner, String repo) async {
    Map<String, int> userPrCounts = {};
    int page = 1;
    bool hasMore = true;

    // Get the start of the current month
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    // final dateFormatter = DateFormat('yyyy-MM-ddTHH:mm:ssZ');

    try {
      while (hasMore) {
        final url = Uri.parse('$baseUrl/repos/$owner/$repo/pulls?state=closed&page=$page');
        final response = await http.get(url, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Authorization':
              'Bearer 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', // Add your GitHub token
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);

          if (data.isEmpty) {
            hasMore = false; // No more pages
          } else {
            for (var pr in data) {
              if (pr['merged_at'] != null) {
                final mergedAt = DateTime.parse(pr['merged_at']);
                // Only count PRs merged in the current month
                if (mergedAt.isAfter(startOfMonth)) {
                  final user = pr['user']['login'];
                  userPrCounts[user] = (userPrCounts[user] ?? 0) + 1;
                }
              }
            }
            page++; // Increment page number for the next request
          }
        } else {
          throw Exception('Failed to fetch PRs for $repo');
        }
        // log(repo);
        // log(userPrCounts.toString());
      }
    } catch (e) {
      log('Error fetching PRs: $e');
    }
    return userPrCounts;
  }
}
