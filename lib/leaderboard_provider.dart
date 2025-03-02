// File: leaderboard_provider.dart - Create this new file
import 'package:flutter/material.dart';

import 'github_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final GithubService _githubService = GithubService();
  Map<String, int> userPrCounts = {};
  bool isLoading = true;

  // Selected month and year
  late DateTime selectedMonth;

  // Generate a list of the last 12 months
  late List<DateTime> availableMonths;

  // Constructor
  LeaderboardProvider() {
    // Initialize with the current month
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);

    // Generate the last 6 months for dropdown
    availableMonths = List.generate(6, (index) {
      return DateTime(now.year, now.month - index);
    });

    fetchMergedPRs();
  }

  void changeMonth(DateTime newMonth) {
    if (newMonth != selectedMonth) {
      selectedMonth = newMonth;
      fetchMergedPRs();
    }
  }

  Future<void> fetchMergedPRs() async {
    isLoading = true;
    userPrCounts = {};
    notifyListeners();

    List<String> repos = ['talawa', 'talawa-docs', 'talawa-admin', 'talawa-api'];

    // Calculate start and end dates for the selected month
    final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0); // Last day of month

    Map<String, int> aggregatedUserPrCounts = {};

    for (String repo in repos) {
      final repoUserPrCounts = await _githubService.getMergedPRs(
        repo,
        startDate: startDate,
        endDate: endDate,
      );

      repoUserPrCounts.forEach((user, count) {
        aggregatedUserPrCounts[user] = (aggregatedUserPrCounts[user] ?? 0) + count;
      });
    }

    // Filter out bot users
    final filteredUserPrCounts = Map.fromEntries(
      aggregatedUserPrCounts.entries.where((entry) => !entry.key.contains('[bot]')),
    );

    // Sort user PR counts in descending order
    final sortedUserPrCounts = Map.fromEntries(
      filteredUserPrCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    userPrCounts = sortedUserPrCounts;
    isLoading = false;
    notifyListeners();
  }
}
