import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../view_models/leaderboard_view_model.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  // Google Material Design colors
  static const Color primaryColor = Color(0xFF4285F4); // Google Blue
  static const Color backgroundColor = Color(0xFFF8F9FA); // Google Gray 50
  static const Color highlightColor = Color(0xFF34A853); // Google Green
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColor = Color(0xFF202124); // Google Gray 900

  // Top 3 position colors - Google's palette
  static const Color firstPlaceColor = Color(0xFF4285F4); // Google Blue
  static const Color secondPlaceColor = Color(0xFF34A853); // Google Green
  static const Color thirdPlaceColor = Color(0xFFFBBC05); // Google Yellow

  Color _getPositionColor(int index) {
    switch (index) {
      case 0:
        return firstPlaceColor;
      case 1:
        return secondPlaceColor;
      case 2:
        return thirdPlaceColor;
      default:
        return cardBackgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Palisadoes Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width:
              MediaQuery.of(context).size.width > 1400 ? 1400 : MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Month selection dropdown with title
              Consumer<LeaderboardViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Month',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DateTime>(
                            value: viewModel.selectedMonth,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: primaryColor),
                            items: viewModel.availableMonths.map((DateTime month) {
                              return DropdownMenuItem<DateTime>(
                                value: month,
                                child: Text(
                                  DateFormat('MMMM yyyy').format(month),
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (DateTime? newMonth) {
                              if (newMonth != null) {
                                viewModel.changeMonth(newMonth);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Column headers with cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_rounded, color: primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Top Contributors',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_rounded, color: primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Top Reviewers',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Leaderboard content
              Expanded(
                child: Consumer<LeaderboardViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoActivityIndicator(radius: 16),
                            SizedBox(height: 16),
                            Text(
                              'Loading statistics...',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final stats = viewModel.stats;
                    if (stats == null) {
                      return const Center(child: Text('No data available'));
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PR Authors column
                        Expanded(
                          child: stats.prCounts.isEmpty
                              ? _buildEmptyState(
                                  'No contributions found',
                                  'No merged PRs for ${DateFormat('MMMM yyyy').format(viewModel.selectedMonth)}',
                                )
                              : _buildLeaderboardList(
                                  stats.prCounts,
                                  'PRs',
                                ),
                        ),
                        const SizedBox(width: 24),
                        // Reviewers column
                        Expanded(
                          child: stats.reviewCounts.isEmpty
                              ? _buildEmptyState(
                                  'No reviews found',
                                  'No PR reviews for ${DateFormat('MMMM yyyy').format(viewModel.selectedMonth)}',
                                )
                              : _buildLeaderboardList(
                                  stats.reviewCounts,
                                  'Reviews',
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(Map<String, int> data, String label) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final username = data.keys.elementAt(index);
        final count = data.values.elementAt(index);
        final isTopThree = index < 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isTopThree ? _getPositionColor(index) : cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Position indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isTopThree ? Colors.white.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isTopThree
                        ? _buildTopThreeIcon(index)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isTopThree ? Colors.white : primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Avatar and username
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isTopThree
                            ? Colors.white.withOpacity(0.2)
                            : primaryColor.withOpacity(0.1),
                        radius: 20,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isTopThree ? Colors.white : primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                color: isTopThree ? Colors.white : textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isTopThree) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getPositionText(index),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        isTopThree ? Colors.white.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(
                          color: isTopThree ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: isTopThree
                              ? Colors.white.withOpacity(0.8)
                              : primaryColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopThreeIcon(int index) {
    IconData icon;
    switch (index) {
      case 0:
        icon = Icons.workspace_premium;
        break;
      case 1:
        icon = Icons.military_tech;
        break;
      case 2:
        icon = Icons.stars;
        break;
      default:
        icon = Icons.emoji_events;
    }
    return Icon(icon, color: Colors.white, size: 20);
  }

  String _getPositionText(int index) {
    switch (index) {
      case 0:
        return 'Gold Medal 🥇';
      case 1:
        return 'Silver Medal 🥈';
      case 2:
        return 'Bronze Medal 🥉';
      default:
        return '';
    }
  }
}
