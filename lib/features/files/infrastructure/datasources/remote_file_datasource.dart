import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:skillshare/core/constants/api_constants.dart';

/// Data source for remote file operations
class RemoteFileDataSource {
  final String _token;

  RemoteFileDataSource(this._token);

  /// Headers for authenticated requests
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  /// Gets group documents
  Future<List<Map<String, dynamic>>> getGroupDocuments(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/group/$groupId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load group documents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching group documents: $e');
      rethrow;
    }
  }

  /// Gets user documents
  Future<List<Map<String, dynamic>>> getUserDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/user'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load user documents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user documents: $e');
      rethrow;
    }
  }

  /// Uploads a document
  Future<Map<String, dynamic>> uploadDocument({
    required int groupId,
    required String title,
    required File file,
    String? description,
    int? subjectId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.documentBase}/upload'),
      );

      request.headers['Authorization'] = 'Bearer $_token';

      request.fields['groupId'] = groupId.toString();
      request.fields['title'] = title;
      if (description != null) {
        request.fields['description'] = description;
      }
      if (subjectId != null) {
        request.fields['subjectId'] = subjectId.toString();
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to upload document: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  /// Deletes a document
  Future<bool> deleteDocument(int documentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.documentBase}/$documentId'),
        headers: _headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  /// Downloads a document
  Future<Map<String, dynamic>> downloadDocument(int documentId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.documentBase}/$documentId/download'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];

        if (contentType?.contains('application/json') == true) {
          return json.decode(response.body) as Map<String, dynamic>;
        } else {
          // Handle direct file download
          final fileName = response.headers['content-disposition']
              ?.split('filename=')
              .last
              .replaceAll('"', '') ?? 'document_$documentId';

          return {
            'fileBytes': response.bodyBytes,
            'fileName': fileName,
            'isDirectDownload': true,
          };
        }
      } else {
        throw Exception('Failed to download document: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading document: $e');
      rethrow;
    }
  }

  /// Gets global statistics
  Future<Map<String, dynamic>> getGlobalStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/statistics/global'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load global statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching global statistics: $e');
      rethrow;
    }
  }

  /// Toggles favorite status for a document
  Future<bool> toggleFavorite(int documentId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.documentBase}/$documentId/favorite'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        return result['isFavorite'] as bool;
      } else {
        throw Exception('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Gets favorite documents
  Future<List<Map<String, dynamic>>> getFavoriteDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/favorites'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load favorite documents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorite documents: $e');
      rethrow;
    }
  }
}