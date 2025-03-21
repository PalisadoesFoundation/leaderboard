import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/github_constants.dart';

class GithubService {
  final String authToken;

  GithubService({required this.authToken});

  bool _shouldExcludeAuthor(String username) {
    final lowerUsername = username.toLowerCase();
    return GithubConstants.excludedUsers.contains(lowerUsername) ||
        GithubConstants.excludedAuthors.contains(lowerUsername) ||
        lowerUsername.endsWith('[bot]') ||
        lowerUsername.contains('bot') ||
        lowerUsername.contains('actions') ||
        lowerUsername.contains('pipeline') ||
        lowerUsername.contains('automation') ||
        lowerUsername == 'undefined' ||
        lowerUsername == 'null';
  }

  bool _shouldExcludeReviewer(String username) {
    final lowerUsername = username.toLowerCase();
    return GithubConstants.excludedUsers.contains(lowerUsername) ||
        lowerUsername.endsWith('[bot]') ||
        lowerUsername.contains('bot') ||
        lowerUsername.contains('actions') ||
        lowerUsername.contains('pipeline') ||
        lowerUsername.contains('automation') ||
        lowerUsername == 'undefined' ||
        lowerUsername == 'null';
  }

  Future<(Map<String, int>, Map<String, int>)> getMergedPRsAndReviews(
    String repo, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, int> userPrCounts = {};
    Map<String, int> userReviewCounts = {};

    final now = DateTime.now();
    startDate ??= DateTime(now.year, now.month, 1);
    endDate ??= DateTime(now.year, now.month + 1, 0);

    String cursor = "";
    bool hasNextPage = true;

    try {
      while (hasNextPage) {
        final String query = '''
        {
          repository(owner: "${GithubConstants.owner}", name: "$repo") {
            pullRequests(first: 50, after: ${cursor.isEmpty ? "null" : '"$cursor"'}, orderBy: {field: CREATED_AT, direction: DESC}, states: [MERGED]) {
              pageInfo {
                hasNextPage
                endCursor
              }
              nodes {
                number
                author {
                  login
                }
                mergedAt
                reviews(first: 100) {
                  nodes {
                    author {
                      login
                    }
                  }
                }
              }
            }
          }
        }
        ''';

        final response = await http.post(
          Uri.parse(GithubConstants.baseUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'query': query}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['data'] != null) {
            final prs = data['data']['repository']['pullRequests'];
            final pageInfo = prs['pageInfo'];
            hasNextPage = pageInfo['hasNextPage'];
            cursor = pageInfo['endCursor'] ?? "";

            bool foundOlderPR = false;

            for (var pr in prs['nodes']) {
              if (pr['mergedAt'] != null && pr['author'] != null) {
                final mergedAt = DateTime.parse(pr['mergedAt']);

                if (mergedAt.isBefore(startDate)) {
                  foundOlderPR = true;
                  continue;
                }

                if (mergedAt.isAfter(endDate)) {
                  continue;
                }

                final author = pr['author']['login'];
                if (!_shouldExcludeAuthor(author)) {
                  userPrCounts[author] = (userPrCounts[author] ?? 0) + 1;
                }

                final reviews = pr['reviews']['nodes'];
                for (var review in reviews) {
                  if (review['author'] != null) {
                    final reviewer = review['author']['login'];
                    if (!_shouldExcludeReviewer(reviewer) && reviewer != author) {
                      userReviewCounts[reviewer] = (userReviewCounts[reviewer] ?? 0) + 1;
                    }
                  }
                }
              }
            }

            if (foundOlderPR) {
              hasNextPage = false;
            }
          } else {
            log('GraphQL error: ${data['errors']}');
            hasNextPage = false;
          }
        } else {
          log('Failed to fetch data: ${response.statusCode} ${response.body}');
          hasNextPage = false;
        }
      }
    } catch (e) {
      log('Error fetching PRs and reviews: $e');
    }

    return (userPrCounts, userReviewCounts);
  }
}
