import 'package:flutter/material.dart';

import 'leaderboard_page.dart';

void main() {
  runApp(const GithubLeaderboardApp());
}

class GithubLeaderboardApp extends StatelessWidget {
  const GithubLeaderboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub PR Leaderboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LeaderboardPage(),
    );
  }
}
