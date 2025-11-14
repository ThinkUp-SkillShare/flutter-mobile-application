import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../groups/services/group_service.dart';
import '../../../shared/subject/subject_utils.dart';

class SearchViewModel with ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<Map<String, dynamic>> _allGroups = [];
  List<Map<String, dynamic>> _filteredGroups = [];
  List<Map<String, dynamic>> _recommendedGroups = [];
  List<Map<String, dynamic>> _popularGroups = [];
  List<Map<String, dynamic>> _trendingGroups = [];
  List<Map<String, dynamic>> _newGroups = [];
  List<Map<String, dynamic>> _subjects = [];

  String _selectedCategory = 'All';
  bool _isSearching = false;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> get allGroups => _allGroups;
  List<Map<String, dynamic>> get filteredGroups => _filteredGroups;
  List<Map<String, dynamic>> get recommendedGroups => _recommendedGroups;
  List<Map<String, dynamic>> get popularGroups => _popularGroups;
  List<Map<String, dynamic>> get trendingGroups => _trendingGroups;
  List<Map<String, dynamic>> get newGroups => _newGroups;
  List<Map<String, dynamic>> get subjects => _subjects;
  String get selectedCategory => _selectedCategory;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalGroups => _allGroups.length;
  int get totalStudents {
    int count = 0;
    for (var group in _allGroups) {
      count += (group['memberCount'] as int? ?? 0);
    }
    return count;
  }
  int get totalDocuments {
    return (_allGroups.length * 2).round();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception('No authentication data found');
      }

      final results = await Future.wait([
        GroupService.getAllGroups(token),
        GroupService.getFeaturedGroups(userId, token),
        GroupService.getAllSubjects(token),
      ]);

      _allGroups = results[0] as List<Map<String, dynamic>>;
      final featured = results[1] as List<Map<String, dynamic>>;
      _subjects = results[2] as List<Map<String, dynamic>>;

      _processGroups(_allGroups, featured);
      _debugGroupData();

      _filteredGroups = _allGroups;
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _error = 'Error loading data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processGroups(List<Map<String, dynamic>> groups, List<Map<String, dynamic>> featured) {
    _recommendedGroups = featured.take(3).toList();

    _popularGroups = List.from(groups)
      ..sort((a, b) => (b['memberCount'] ?? 0).compareTo(a['memberCount'] ?? 0));
    _popularGroups = _popularGroups.take(4).toList();

    _trendingGroups = List.from(groups)
      ..sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
        final bDate = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());

        final aRecency = DateTime.now().difference(aDate).inDays < 7 ? 50 : 0;
        final bRecency = DateTime.now().difference(bDate).inDays < 7 ? 50 : 0;

        final aScore = (a['memberCount'] ?? 0) + aRecency;
        final bScore = (b['memberCount'] ?? 0) + bRecency;

        return bScore.compareTo(aScore);
      });
    _trendingGroups = _trendingGroups.take(2).toList();

    _newGroups = List.from(groups)
      ..sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
        final bDate = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());
        return bDate.compareTo(aDate);
      });
    _newGroups = _newGroups.take(2).toList();
  }


  void _debugGroupData() {
    print('🔍 DEBUG: Group data analysis');
    print('Total groups: ${_allGroups.length}');

    int groupsWithCoverImage = 0;
    int groupsWithCover_image = 0;

    for (var i = 0; i < _allGroups.length && i < 5; i++) {
      final group = _allGroups[i];
      print('Group ${i + 1}: "${group['name']}"');
      print('   - coverImage: ${group['coverImage']}');
      print('   - cover_image: ${group['cover_image']}');
      print('   - subjectName: ${group['subjectName']}');
      print('   - memberCount: ${group['memberCount']}');

      if (group['coverImage'] != null && group['coverImage'].toString().isNotEmpty) {
        groupsWithCoverImage++;
      }
      if (group['cover_image'] != null && group['cover_image'].toString().isNotEmpty) {
        groupsWithCover_image++;
      }
    }

    print('Groups with coverImage: $groupsWithCoverImage');
    print('Groups with cover_image: $groupsWithCover_image');
  }

  void _processSubjects(List<Map<String, dynamic>> allGroups, List<Map<String, dynamic>> subjects) {
    final processedSubjects = SubjectUtils.processSubjectsWithGroups(subjects, allGroups);

    _subjects = processedSubjects;
  }

  Future<bool> joinGroup(int groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        return await GroupService.joinGroup(groupId, token);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  int? _currentSubjectFilterId;
  String _currentSearchQuery = '';

  int? get currentSubjectFilterId => _currentSubjectFilterId;
  String get currentSearchQuery => _currentSearchQuery;

  void filterBySubject(int subjectId) {
    _currentSubjectFilterId = subjectId;
    _selectedCategory = _getSubjectNameById(subjectId) ?? 'All';
    _applyFilters();
  }

  void clearSubjectFilter() {
    _currentSubjectFilterId = null;
    _selectedCategory = 'All';
    _applyFilters();
  }

  void filterGroups(String query) {
    _currentSearchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allGroups;

    if (_currentSubjectFilterId != null) {
      filtered = filtered.where((g) => g['subjectId'] == _currentSubjectFilterId).toList();
    }

    if (_currentSearchQuery.isNotEmpty) {
      final lowercaseQuery = _currentSearchQuery.toLowerCase();
      filtered = filtered.where((group) {
        final name = (group['name'] ?? '').toString().toLowerCase();
        final description = (group['description'] ?? '').toString().toLowerCase();
        final subject = (group['subjectName'] ?? '').toString().toLowerCase();
        return name.contains(lowercaseQuery) ||
            description.contains(lowercaseQuery) ||
            subject.contains(lowercaseQuery);
      }).toList();
    }

    _filteredGroups = filtered;
    _isSearching = _currentSearchQuery.isNotEmpty || _currentSubjectFilterId != null;
    notifyListeners();
  }

  String? _getSubjectNameById(int subjectId) {
    try {
      final subject = _subjects.firstWhere(
            (s) => s['id'] == subjectId,
        orElse: () => {},
      );
      return subject['name'] as String?;
    } catch (e) {
      return null;
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'All') {
      clearSubjectFilter();
    } else {
      final subject = _subjects.firstWhere(
            (s) => s['name'] == category,
        orElse: () => {'id': 0},
      );
      if (subject['id'] != 0) {
        filterBySubject(subject['id'] as int);
      }
    }
  }
}