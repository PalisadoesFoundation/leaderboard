import 'dart:developer';

import 'package:flutter/material.dart';

import 'github_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  final GithubService _githubService = GithubService();
  Map<String, int> userPrCounts = {
    'gautam-divyanshu': 6,
    'palisadoes': 3,
    'JordanCampbell1': 2,
    'ARYANSHAH1567': 1,
    'Suyash878': 1,
    'disha1202': 1
  };

  @override
  void initState() {
    super.initState();
    // fetchMergedPRs();
  }

  Future<void> fetchMergedPRs() async {
    List<String> repos = ['talawa', 'talawa-docs', 'talawa-admin', 'talawa-api'];

    Map<String, int> aggregatedUserPrCounts = {};

    for (String repo in repos) {
      final repoUserPrCounts = await _githubService.getMergedPRs('PalisadoesFoundation', repo);
      repoUserPrCounts.forEach((user, count) {
        aggregatedUserPrCounts[user] = (aggregatedUserPrCounts[user] ?? 0) + count;
      });
    }

    setState(() {
      userPrCounts = aggregatedUserPrCounts;
    });

    // Sort user PR counts in descending order
    userPrCounts = Map.fromEntries(
      userPrCounts.entries.toList()
        ..sort(
            (a, b) => b.value.compareTo(a.value)), // Sort by values (PR counts) in descending order
    );
  }

  @override
  Widget build(BuildContext context) {
    log(userPrCounts.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub PR Leaderboard'),
      ),
      body: userPrCounts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userPrCounts.length,
              itemBuilder: (context, index) {
                final user = userPrCounts.keys.elementAt(index);
                final prCount = userPrCounts[user];
                return ListTile(
                  title: Text(user),
                  trailing: Text('$prCount PRs'),
                );
              },
            ),
    );
  }
}
