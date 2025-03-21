import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/models/github_stats.dart';
import '../repositories/github_repository.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final GithubRepository _repository;

  GithubStats? _stats;
  bool _isLoading = false;
  String? _error;
  DateTime _selectedMonth;
  final List<DateTime> _availableMonths;

  LeaderboardViewModel({
    required GithubRepository repository,
  })  : _repository = repository,
        _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month),
        _availableMonths = List.generate(6, (index) {
          final now = DateTime.now();
          return DateTime(now.year, now.month - index);
        }) {
    // Fetch data immediately when ViewModel is created
    fetchStats();
  }

  // Getters
  GithubStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;
  List<DateTime> get availableMonths => _availableMonths;

  // Methods
  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      _stats = await _repository.fetchMonthlyStats(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      log('Error fetching stats: $e');
      _error = 'Failed to fetch leaderboard data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeMonth(DateTime newMonth) {
    if (newMonth != _selectedMonth) {
      _selectedMonth = newMonth;
      fetchStats();
    }
  }
}
