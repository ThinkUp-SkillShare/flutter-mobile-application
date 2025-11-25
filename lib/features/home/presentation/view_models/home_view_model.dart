import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../groups/services/group_service.dart';
import '../../../shared/subject/subject_utils.dart';

/// ViewModel responsible for managing the home screen data.
/// Handles user authentication data, loading featured groups,
/// detecting popular subjects, auto-refreshing data, and notifying the UI.
class HomeViewModel with ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<Map<String, dynamic>> _featuredGroups = [];
  List<Map<String, dynamic>> _popularSubjects = [];

  bool _isLoading = false;
  String? _error;
  String? _token;
  int? _userId;

  List<Map<String, dynamic>> get featuredGroups => _featuredGroups;
  List<Map<String, dynamic>> get popularSubjects => _popularSubjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Timer? _refreshTimer;

  HomeViewModel() {
    _loadUserData();
    _startAutoRefresh();
  }

  /// Starts a periodic background refresh every 30 seconds.
  /// This ensures the home screen stays updated without requiring user actions.
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading) {
        _refreshDataSilently();
      }
    });
  }

  /// Refreshes home data without showing loading indicators.
  /// Used for background updates triggered by the auto-refresh timer.
  Future<void> _refreshDataSilently() async {
    try {
      final newFeaturedGroups =
      await GroupService.getFeaturedGroups(_userId!, _token!);

      final allGroups = await GroupService.getAllGroups(_token!);
      final allSubjects = await GroupService.getAllSubjects(_token!);

      final newPopularSubjects =
      SubjectUtils.getPopularSubjects(allSubjects, allGroups);

      /// Only notify UI when meaningful data changes occur.
      if (_hasDataChanged(newFeaturedGroups, newPopularSubjects)) {
        _featuredGroups = newFeaturedGroups;
        _popularSubjects = newPopularSubjects;
        notifyListeners();
      }
    } catch (_) {
      // Silent failure: auto-refresh should not break UI experience.
    }
  }

  /// Compares old and new data to determine if UI should refresh.
  /// Prevents unnecessary widget rebuilds.
  bool _hasDataChanged(
      List<Map<String, dynamic>> newFeaturedGroups,
      List<Map<String, dynamic>> newPopularSubjects,
      ) {
    if (newFeaturedGroups.length != _featuredGroups.length) return true;

    for (int i = 0; i < newFeaturedGroups.length; i++) {
      final newGroup = newFeaturedGroups[i];
      final oldGroup = _featuredGroups[i];

      /// If essential group attributes changed, we consider the data updated.
      if (newGroup['id'] != oldGroup['id'] ||
          newGroup['memberCount'] != oldGroup['memberCount']) {
        return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Loads stored authentication data from SharedPreferences.
  /// If missing, marks the ViewModel as unauthenticated.
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getInt('user_id');

    if (_token == null || _userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
    }
  }

  /// Public method to load all home screen data.
  /// Ensures the user is authenticated, then loads everything sequentially.
  Future<void> loadHomeData() async {
    if (_token == null || _userId == null) {
      await _loadUserData();
      if (_token == null || _userId == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadFeaturedGroups();
      await _loadPopularSubjects();
    } catch (e) {
      _error = 'Error loading home data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads featured groups from the backend.
  Future<void> _loadFeaturedGroups() async {
    _featuredGroups =
    await GroupService.getFeaturedGroups(_userId!, _token!);
  }

  /// Loads all groups and subjects, then computes the "popular subjects"
  /// based on their usage within groups.
  Future<void> _loadPopularSubjects() async {
    final allGroups = await GroupService.getAllGroups(_token!);
    final allSubjects = await GroupService.getAllSubjects(_token!);

    _popularSubjects =
        SubjectUtils.getPopularSubjects(allSubjects, allGroups);
  }

  /// Public method for manually refreshing home screen data.
  Future<void> refreshData() async {
    await loadHomeData();
  }
}
