import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skillshare/features/auth/application/auth_service.dart';

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

  Timer? _refreshTimer;
  bool _isDisposed = false;

  List<Map<String, dynamic>> get featuredGroups => _featuredGroups;

  List<Map<String, dynamic>> get popularSubjects => _popularSubjects;

  bool get isLoading => _isLoading;

  String? get error => _error;

  HomeViewModel() {
    _loadUserData();
    _startAutoRefresh();
  }

  /// Loads stored authentication data and validates token
  Future<void> _loadUserData() async {
    try {
      // Get and validate token
      _token = await AuthService.getValidToken();

      if (_token == null) {
        _error = 'Session expired. Please login again.';
        if (!_isDisposed) notifyListeners();
        return;
      }

      // Get user ID
      _userId = await AuthService.getStoredUserId();

      if (_userId == null || _userId! <= 0) {
        _error = 'User not authenticated';
        if (!_isDisposed) notifyListeners();
        return;
      }

      // Clear any previous errors
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: $e';
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Starts a periodic background refresh every 30 seconds.
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading && !_isDisposed) {
        _refreshDataSilently();
      }
    });
  }

  /// Refreshes home data without showing loading indicators.
  Future<void> _refreshDataSilently() async {
    try {
      // Validate token before making requests
      final validToken = await AuthService.getValidToken();
      if (validToken == null) {
        _token = null;
        _error = 'Session expired. Please login again.';
        if (!_isDisposed) notifyListeners();
        return;
      }

      // Only refresh if token has changed or is newly validated
      if (_token != validToken) {
        _token = validToken;
      }

      final newFeaturedGroups = await GroupService.getFeaturedGroups(
        _userId!,
        _token!,
      );
      final allGroups = await GroupService.getAllGroups(_token!);
      final allSubjects = await GroupService.getAllSubjects(_token!);
      final newPopularSubjects = SubjectUtils.getPopularSubjects(
        allSubjects,
        allGroups,
      );

      if (_hasDataChanged(newFeaturedGroups, newPopularSubjects)) {
        _featuredGroups = newFeaturedGroups;
        _popularSubjects = newPopularSubjects;
        if (!_isDisposed) notifyListeners();
      }
    } catch (_) {
      // Silent failure for auto-refresh
    }
  }

  /// Compares old and new data to determine if UI should refresh.
  bool _hasDataChanged(
    List<Map<String, dynamic>> newFeaturedGroups,
    List<Map<String, dynamic>> newPopularSubjects,
  ) {
    if (newFeaturedGroups.length != _featuredGroups.length ||
        newPopularSubjects.length != _popularSubjects.length) {
      return true;
    }

    for (int i = 0; i < newFeaturedGroups.length; i++) {
      final newGroup = newFeaturedGroups[i];
      final oldGroup = i < _featuredGroups.length ? _featuredGroups[i] : {};

      if (newGroup['id'] != oldGroup['id'] ||
          newGroup['memberCount'] != oldGroup['memberCount']) {
        return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Public method to load all home screen data.
  Future<void> loadHomeData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();

    try {
      // Always refresh token before loading data
      await _loadUserData();

      if (_token == null || _userId == null) {
        _error = 'Please login to continue';
        return;
      }

      await _loadFeaturedGroups();
      await _loadPopularSubjects();
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Gets user-friendly error messages
  String _getErrorMessage(dynamic e) {
    final errorStr = e.toString().toLowerCase();

    if (errorStr.contains('token') ||
        errorStr.contains('expired') ||
        errorStr.contains('401')) {
      return 'Session expired. Please login again.';
    } else if (errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorStr.contains('permission') || errorStr.contains('403')) {
      return 'You do not have permission to access this data.';
    } else {
      return 'Failed to load home data. Please try again.';
    }
  }

  /// Loads featured groups from the backend.
  Future<void> _loadFeaturedGroups() async {
    try {
      _featuredGroups = await GroupService.getFeaturedGroups(
        _userId!,
        _token!,
      );
    } catch (e) {
      throw Exception('Failed to load featured groups: $e');
    }
  }

  /// Loads all groups and subjects, then computes the popular subjects.
  Future<void> _loadPopularSubjects() async {
    try {
      final allGroups = await GroupService.getAllGroups(_token!);
      final allSubjects = await GroupService.getAllSubjects(_token!);
      _popularSubjects = SubjectUtils.getPopularSubjects(
        allSubjects,
        allGroups,
      );
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  /// Public method for manually refreshing home screen data.
  Future<void> refreshData() async {
    await loadHomeData();
  }

  /// Logs out the user and clears all data
  Future<void> logout() async {
    await AuthService.logout();
    _featuredGroups = [];
    _popularSubjects = [];
    _token = null;
    _userId = null;
    _error = 'User logged out';
    if (!_isDisposed) notifyListeners();
  }
}
