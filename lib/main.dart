import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/services/github_service.dart';
import 'features/leaderboard/repositories/github_repository.dart';
import 'features/leaderboard/view_models/leaderboard_view_model.dart';
import 'features/leaderboard/views/leaderboard_view.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const GithubLeaderboardApp());
}

class GithubLeaderboardApp extends StatelessWidget {
  const GithubLeaderboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final githubToken = dotenv.env['GH_TOKEN'] ?? '';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub PR Leaderboard',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4285F4),
          secondary: Color(0xFF34A853),
          surface: Color(0xFFF8F9FA),
          error: Color(0xFFEA4335),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 1,
          backgroundColor: Color(0xFF4285F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: MultiProvider(
        providers: [
          Provider<GithubService>(
            create: (_) => GithubService(authToken: githubToken),
          ),
          ProxyProvider<GithubService, GithubRepository>(
            update: (_, service, __) => GithubRepository(githubService: service),
          ),
          ChangeNotifierProxyProvider<GithubRepository, LeaderboardViewModel>(
            create: (context) => LeaderboardViewModel(
              repository: context.read<GithubRepository>(),
            ),
            update: (_, repository, viewModel) =>
                viewModel ??
                LeaderboardViewModel(
                  repository: repository,
                ),
          ),
        ],
        child: const LeaderboardView(),
      ),
    );
  }
}
