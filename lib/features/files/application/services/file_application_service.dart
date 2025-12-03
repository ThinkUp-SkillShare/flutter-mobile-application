import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/document.dart';
import '../../domain/repositories/file_repository.dart';

/// Application service for file operations
class FileApplicationService {
  final FileRepository _fileRepository;

  FileApplicationService(this._fileRepository);

  /// Loads documents based on context
  Future<List<Document>> loadDocuments({int? groupId}) async {
    if (groupId != null) {
      return await _fileRepository.getGroupDocuments(groupId);
    } else {
      return await _fileRepository.getAllDocuments();
    }
  }

  /// Uploads a document with validation
  Future<Document> uploadDocument({
    required int groupId,
    required String title,
    required String filePath,
    String? description,
    int? subjectId,
  }) async {
    if (title.isEmpty) {
      throw Exception('Title is required');
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File does not exist');
    }

    final fileSize = await file.length();
    if (fileSize > 50 * 1024 * 1024) {
      throw Exception('File size exceeds 50MB limit');
    }

    return await _fileRepository.uploadDocument(
      groupId: groupId,
      title: title,
      filePath: filePath,
      description: description,
      subjectId: subjectId,
    );
  }

  /// Deletes a document with confirmation
  Future<bool> deleteDocument(int documentId) async {
    return await _fileRepository.deleteDocument(documentId);
  }

  /// Downloads a document and saves it locally
  Future<File> downloadAndSaveDocument(int documentId) async {
    final result = await _fileRepository.downloadDocument(documentId);

    if (result['isDirectDownload'] == true) {
      final bytes = result['fileBytes'] as List<int>;
      final fileName = result['fileName'] as String;

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      return file;
    } else {
      final downloadUrl = result['downloadUrl'] as String;
      // Handle external URL download
      throw Exception('External URL download not yet implemented');
    }
  }

  /// Gets statistics based on context
  Future<Map<String, dynamic>> getStatistics({int? groupId}) async {
    if (groupId != null) {
      return await _fileRepository.getGroupStatistics(groupId);
    } else {
      return await _fileRepository.getGlobalStatistics();
    }
  }

  /// Toggles favorite status and updates document
  Future<Document> toggleFavoriteDocument(Document document) async {
    final isFavorite = await _fileRepository.toggleFavorite(document.id);

    return document.copyWith(
      isFavorite: isFavorite,
      favoriteCount: isFavorite
          ? document.favoriteCount + 1
          : document.favoriteCount - 1,
    );
  }

  /// Filters documents based on search query and tab
  List<Document> filterDocuments({
    required List<Document> documents,
    required String searchQuery,
    required int tabIndex,
    int? currentUserId,
  }) {
    List<Document> filtered = List.from(documents);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((doc) {
        return doc.title.toLowerCase().contains(query) ||
            (doc.description?.toLowerCase().contains(query) ?? false) ||
            doc.fileName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply tab filter
    final now = DateTime.now();
    switch (tabIndex) {
      case 1: // Recent (last 7 days)
        filtered = filtered.where((doc) {
          return now.difference(doc.uploadDate).inDays <= 7;
        }).toList();
        break;
      case 2: // Favorites
        filtered = filtered.where((doc) => doc.isFavorite).toList();
        break;
      case 3: // My uploads
        if (currentUserId != null) {
          filtered = filtered.where((doc) => doc.userId == currentUserId).toList();
        }
        break;
    }

    return filtered;
  }
}