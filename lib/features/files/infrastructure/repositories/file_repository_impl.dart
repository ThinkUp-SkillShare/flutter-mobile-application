import 'dart:io';

import '../../domain/entities/document.dart';
import '../../domain/repositories/file_repository.dart';
import '../datasources/remote_file_datasource.dart';

/// Implementation of FileRepository using remote data source
class FileRepositoryImpl implements FileRepository {
  final RemoteFileDataSource _dataSource;

  FileRepositoryImpl(this._dataSource);

  @override
  Future<List<Document>> getGroupDocuments(int groupId) async {
    try {
      final data = await _dataSource.getGroupDocuments(groupId);
      return data.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      print('Error in getGroupDocuments: $e');
      rethrow;
    }
  }

  @override
  Future<List<Document>> getUserDocuments() async {
    try {
      final data = await _dataSource.getUserDocuments();
      return data.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      print('Error in getUserDocuments: $e');
      rethrow;
    }
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    // For simplicity, returning user documents
    // In a real app, this might combine multiple sources
    return await getUserDocuments();
  }

  @override
  Future<Document> uploadDocument({
    required int groupId,
    required String title,
    required String filePath,
    String? description,
    int? subjectId,
  }) async {
    try {
      final file = File(filePath);
      final data = await _dataSource.uploadDocument(
        groupId: groupId,
        title: title,
        file: file,
        description: description,
        subjectId: subjectId,
      );
      return Document.fromJson(data);
    } catch (e) {
      print('Error in uploadDocument: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteDocument(int documentId) async {
    try {
      return await _dataSource.deleteDocument(documentId);
    } catch (e) {
      print('Error in deleteDocument: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> downloadDocument(int documentId) async {
    try {
      return await _dataSource.downloadDocument(documentId);
    } catch (e) {
      print('Error in downloadDocument: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getGroupStatistics(int groupId) async {
    try {
      // This endpoint doesn't exist in provided backend
      // For now, calculate locally
      final documents = await getGroupDocuments(groupId);
      return {
        'totalDocuments': documents.length,
        'totalSize': documents.fold<int>(0, (sum, doc) => sum + (doc.fileSize ?? 0)),
        'pdfCount': documents.where((d) => d.fileType == 'pdf').length,
        'documentCount': documents.where((d) => d.fileType == 'document').length,
        'imageCount': documents.where((d) => d.fileType == 'image').length,
      };
    } catch (e) {
      print('Error in getGroupStatistics: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalStatistics() async {
    try {
      return await _dataSource.getGlobalStatistics();
    } catch (e) {
      print('Error in getGlobalStatistics: $e');
      // Return default statistics
      return {
        'totalDocuments': 0,
        'myDocuments': 0,
        'totalSize': 0,
      };
    }
  }

  @override
  Future<bool> toggleFavorite(int documentId) async {
    try {
      return await _dataSource.toggleFavorite(documentId);
    } catch (e) {
      print('Error in toggleFavorite: $e');
      // Since the endpoint might not exist yet, simulate success
      return true;
    }
  }

  @override
  Future<List<Document>> getFavoriteDocuments() async {
    try {
      final data = await _dataSource.getFavoriteDocuments();
      return data.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      print('Error in getFavoriteDocuments: $e');
      // Return empty list if endpoint doesn't exist
      return [];
    }
  }
}