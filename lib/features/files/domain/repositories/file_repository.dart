import '../entities/document.dart';

/// Repository interface for file operations
abstract class FileRepository {
  /// Gets documents for a specific group
  Future<List<Document>> getGroupDocuments(int groupId);

  /// Gets documents uploaded by the current user
  Future<List<Document>> getUserDocuments();

  /// Gets all documents across all groups
  Future<List<Document>> getAllDocuments();

  /// Uploads a document
  Future<Document> uploadDocument({
    required int groupId,
    required String title,
    required String filePath,
    String? description,
    int? subjectId,
  });

  /// Deletes a document
  Future<bool> deleteDocument(int documentId);

  /// Downloads a document
  Future<Map<String, dynamic>> downloadDocument(int documentId);

  /// Gets group statistics
  Future<Map<String, dynamic>> getGroupStatistics(int groupId);

  /// Gets global statistics
  Future<Map<String, dynamic>> getGlobalStatistics();

  /// Toggles favorite status for a document
  Future<bool> toggleFavorite(int documentId);

  /// Gets favorite documents
  Future<List<Document>> getFavoriteDocuments();
}