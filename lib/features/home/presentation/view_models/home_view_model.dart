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

  HomeViewModel() {
    _loadUserData();
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