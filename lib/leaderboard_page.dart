// File: leaderboard_page.dart - Update existing file
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'leaderboard_provider.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  // Palisadoes/Talawa colors
  static const Color primaryColor = Color(0xFF31BB6B); // Green primary color
  static const Color backgroundColor = Color(0xFFF7FAF7); // Lighter background
  static const Color highlightColor = Color(0xFF8CC542); // Highlight green for "You"

  // Top 3 position colors - softer, more modern palette
  static const Color firstPlaceColor = Color(0xFFE63946); // Bold Scarlet Red
  static const Color secondPlaceColor = Color(0xFFF77F00); // Rich Sunset Orange
  static const Color thirdPlaceColor = Color(0xFFF4A261); // Warm Golden Amber

  Color _getPositionColor(int index) {
    switch (index) {
      case 0:
        return firstPlaceColor;
      case 1:
        return secondPlaceColor;
      case 2:
        return thirdPlaceColor;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LeaderboardProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'GitHub PR Leaderboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
        ),
        backgroundColor: backgroundColor,
        body: Center(
          child: SizedBox(
            width:
                MediaQuery.of(context).size.width > 700 ? 700 : MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // Month selection dropdown
                Consumer<LeaderboardProvider>(
                  builder: (context, leaderboardState, child) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: primaryColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<DateTime>(
                                  value: leaderboardState.selectedMonth,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                                  items: leaderboardState.availableMonths.map((DateTime month) {
                                    return DropdownMenuItem<DateTime>(
                                      value: month,
                                      child: Text(
                                        DateFormat('MMMM yyyy').format(month),
                                        style: const TextStyle(color: primaryColor),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (DateTime? newMonth) {
                                    if (newMonth != null) {
                                      leaderboardState.changeMonth(newMonth);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Leaderboard content
                Expanded(
                  child: Consumer<LeaderboardProvider>(
                    builder: (context, leaderboardState, child) {
                      if (leaderboardState.isLoading) {
                        return const Center(child: CupertinoActivityIndicator(color: primaryColor));
                      } else if (leaderboardState.userPrCounts.isEmpty) {
                        return Center(
                          child: Text(
                            'No PRs found for ${DateFormat('MMMM yyyy').format(leaderboardState.selectedMonth)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: leaderboardState.userPrCounts.length,
                          itemBuilder: (context, index) {
                            final username = leaderboardState.userPrCounts.keys.elementAt(index);
                            final prCount = leaderboardState.userPrCounts.values.elementAt(index);
                            final isCurrentUser = username == 'You'; // Replace with actual logic

                            // Determine card color based on position and current user status
                            Color cardColor =
                                isCurrentUser ? highlightColor : _getPositionColor(index);
                            Color textColor =
                                (index < 3 || isCurrentUser) ? Colors.white : Colors.black87;
                            Color pointsColor =
                                (index < 3 || isCurrentUser) ? Colors.white : primaryColor;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: index < 3 ? cardColor : Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    // Rank number with special styling for top 3
                                    SizedBox(
                                      width: 30,
                                      child: _buildRankWidget(index),
                                    ),
                                    const SizedBox(width: 12),
                                    // Avatar placeholder
                                    CircleAvatar(
                                      backgroundColor: index < 3
                                          ? Colors.white.withOpacity(0.3)
                                          : primaryColor.withOpacity(0.2),
                                      radius: 16,
                                      child: Text(
                                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                                        style: TextStyle(
                                          color: index < 3 ? cardColor : primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Username
                                    Expanded(
                                      child: Text(
                                        username,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: index < 3 ? textColor : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    // PR count with "pts" label
                                    Text(
                                      '$prCount Merged PRs',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: index < 3 ? pointsColor : primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankWidget(int index) {
    // For top 3, display medals or special indicators
    if (index < 3) {
      IconData icon;
      switch (index) {
        case 0:
          icon = Icons.emoji_events; // Trophy icon for 1st place
          break;
        case 1:
          icon = Icons.looks_two; // Number 2 icon
          break;
        case 2:
          icon = Icons.looks_3; // Number 3 icon
          break;
        default:
          icon = Icons.emoji_events;
      }

      return Icon(
        icon,
        color: Colors.white,
        size: 20,
      );
    } else {
      // For other positions, just show the number
      return Text(
        '${index + 1}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}
