import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/document.dart';
import '../../application/services/file_application_service.dart';

/// ViewModel for files screen
class FilesViewModel with ChangeNotifier {
  final FileApplicationService _fileService;
  final int? _currentUserId;
  final int? _groupId;
  final String? _groupName;

  // State
  List<Document> _documents = [];
  List<Document> _filteredDocuments = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  bool _isGridView = false;
  bool _isSearchVisible = false;
  String _searchQuery = '';
  int _currentTab = 0;
  final Set<int> _favoriteIds = {};

  FilesViewModel({
    required FileApplicationService fileService,
    int? currentUserId,
    int? groupId,
    String? groupName,
  }) : _fileService = fileService,
        _currentUserId = currentUserId,
        _groupId = groupId,
        _groupName = groupName {
    _loadData();
  }

  // Getters
  List<Document> get documents => _filteredDocuments;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;
  bool get isSearchVisible => _isSearchVisible;
  String get searchQuery => _searchQuery;
  int get currentTab => _currentTab;
  String? get groupName => _groupName;

  /// Loads initial data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load documents
      _documents = await _fileService.loadDocuments(groupId: _groupId);

      // Load statistics
      _statistics = await _fileService.getStatistics(groupId: _groupId);

      // Update favorite IDs
      _favoriteIds.clear();
      _favoriteIds.addAll(_documents.where((d) => d.isFavorite).map((d) => d.id));

      // Apply filters
      _applyFilters();
    } catch (e) {
      print('Error loading data: $e');
      // Initialize with empty data
      _statistics = {
        'totalDocuments': 0,
        'myDocuments': 0,
        'totalSize': 0,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Applies current filters to documents
  void _applyFilters() {
    _filteredDocuments = _fileService.filterDocuments(
      documents: _documents,
      searchQuery: _searchQuery,
      tabIndex: _currentTab,
      currentUserId: _currentUserId,
    );
  }

  /// Toggles grid/list view
  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Toggles search visibility
  void toggleSearch() {
    _isSearchVisible = !_isSearchVisible;
    if (!_isSearchVisible) {
      _searchQuery = '';
      _applyFilters();
    }
    notifyListeners();
  }

  /// Updates search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Changes current tab
  void changeTab(int index) {
    _currentTab = index;
    _applyFilters();
    notifyListeners();
  }

  /// Refreshes data
  Future<void> refresh() async {
    await _loadData();
  }

  /// Uploads a document
  Future<void> uploadDocument({
    required int groupId,
    required String title,
    required String filePath,
    String? description,
    int? subjectId,
  }) async {
    try {
      await _fileService.uploadDocument(
        groupId: groupId,
        title: title,
        filePath: filePath,
        description: description,
        subjectId: subjectId,
      );

      // Reload data
      await _loadData();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a document
  Future<void> deleteDocument(int documentId) async {
    try {
      await _fileService.deleteDocument(documentId);

      // Remove from local list
      _documents.removeWhere((doc) => doc.id == documentId);
      _applyFilters();

      // Update statistics
      _statistics['totalDocuments'] = (_statistics['totalDocuments'] as int?) ?? 1 - 1;
      if (_currentUserId != null) {
        final deletedDoc = _documents.firstWhere((doc) => doc.id == documentId);
        if (deletedDoc.userId == _currentUserId) {
          _statistics['myDocuments'] = (_statistics['myDocuments'] as int?) ?? 1 - 1;
        }
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggles favorite status for a document
  Future<void> toggleFavorite(int documentId) async {
    try {
      final document = _documents.firstWhere((doc) => doc.id == documentId);
      final updated = await _fileService.toggleFavoriteDocument(document);

      // Update in local list
      final index = _documents.indexWhere((doc) => doc.id == documentId);
      if (index != -1) {
        _documents[index] = updated;
      }

      // Update favorite IDs
      if (updated.isFavorite) {
        _favoriteIds.add(documentId);
      } else {
        _favoriteIds.remove(documentId);
      }

      _applyFilters();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Downloads a document
  Future<void> downloadDocument(int documentId) async {
    try {
      await _fileService.downloadAndSaveDocument(documentId);
    } catch (e) {
      rethrow;
    }
  }

  /// Opens a document
  Future<void> openDocument(Document document) async {
    try {
      final filePath = await _getLocalFilePath(document);

      final file = File(filePath);

      if (!await file.exists()) {
        await downloadDocument(document.id);
      }

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        throw Exception('No se pudo abrir el documento: ${result.message}');
      }

    } catch (e) {
      print('Error al abrir documento: $e');
      rethrow;
    }
  }

  /// Gets local file path for a document
  Future<String> _getLocalFilePath(Document document) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getFileNameWithExtension(document);
    return '${directory.path}/$fileName';
  }

  /// Generates file name with extension
  String _getFileNameWithExtension(Document document) {
    final originalName = document.fileName ?? 'documento';
    final extension = originalName.contains('.')
        ? originalName.substring(originalName.lastIndexOf('.'))
        : _getExtensionFromMimeType(document.fileType);

    return '${document.id}_${document.title}$extension';
  }

  /// Gets extension from MIME type
  String _getExtensionFromMimeType(String? mimeType) {
    if (mimeType == null) return '.bin';

    final mimeToExt = {
      'application/pdf': '.pdf',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
      'application/vnd.ms-powerpoint': '.ppt',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation': '.pptx',
      'image/jpeg': '.jpg',
      'image/png': '.png',
      'text/plain': '.txt',
    };

    return mimeToExt[mimeType] ?? '.bin';
  }
}