import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../groups/services/group_service.dart';
import '../../../shared/subject/subject_utils.dart';

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

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!_isLoading) {
        _refreshDataSilently();
      }
    });
  }

  Future<void> _refreshDataSilently() async {
    try {
      final newFeaturedGroups = await GroupService.getFeaturedGroups(_userId!, _token!);
      final allGroups = await GroupService.getAllGroups(_token!);
      final allSubjects = await GroupService.getAllSubjects(_token!);
      final newPopularSubjects = SubjectUtils.getPopularSubjects(allSubjects, allGroups);

      // Solo actualizar si hay cambios
      if (_hasDataChanged(newFeaturedGroups, newPopularSubjects)) {
        _featuredGroups = newFeaturedGroups;
        _popularSubjects = newPopularSubjects;
        notifyListeners();
        print('🔄 Home data updated automatically');
      }
    } catch (e) {
      print('❌ Silent refresh failed: $e');
    }
  }

  bool _hasDataChanged(
      List<Map<String, dynamic>> newFeaturedGroups,
      List<Map<String, dynamic>> newPopularSubjects,
      ) {
    // Comparar si los featured groups cambiaron
    if (newFeaturedGroups.length != _featuredGroups.length) return true;

    for (int i = 0; i < newFeaturedGroups.length; i++) {
      final newGroup = newFeaturedGroups[i];
      final oldGroup = _featuredGroups[i];

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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getInt('user_id');

    if (_token == null || _userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
  }

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
      print('🔄 Loading featured groups...');
      _featuredGroups = await GroupService.getFeaturedGroups(_userId!, _token!);
      print('✅ Loaded ${_featuredGroups.length} featured groups');

      print('🔄 Loading ALL groups for subjects calculation...');
      final allGroups = await GroupService.getAllGroups(_token!);
      print('✅ Loaded ${allGroups.length} total groups');

      print('🔄 Loading subjects...');
      final allSubjects = await GroupService.getAllSubjects(_token!);
      print('✅ Loaded ${allSubjects.length} subjects');

      _popularSubjects = SubjectUtils.getPopularSubjects(allSubjects, allGroups);
      print('✅ Processed ${_popularSubjects.length} popular subjects');

      SubjectUtils.debugSubjects(_popularSubjects);

    } catch (e) {
      _error = 'Error loading home data: $e';
      print('❌ HomeViewModel Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadHomeData();
  }
}