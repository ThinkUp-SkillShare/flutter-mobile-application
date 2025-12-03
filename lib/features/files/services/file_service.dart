import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:skillshare/core/constants/api_constants.dart';

class FileService {
  static Future<List<Map<String, dynamic>>> getGroupDocuments(
    int groupId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/group/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load group documents: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching group documents: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUserDocuments(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load user documents: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching user documents: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> uploadDocument({
    required int groupId,
    required String title,
    required File file,
    required String token,
    String? description,
    int? subjectId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.documentBase}/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

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

  static Future<bool> deleteDocument(int documentId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.documentBase}/$documentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> downloadDocument(int documentId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/$documentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final document = json.decode(response.body) as Map<String, dynamic>;
        final fileUrl = document['fileUrl'] as String;

        final downloadResponse = await http.get(Uri.parse(fileUrl));

        if (downloadResponse.statusCode == 200) {
          final fileName = document['fileName'] as String? ?? 'document_$documentId';

          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);

          await file.writeAsBytes(downloadResponse.bodyBytes);

          return {
            'filePath': filePath,
            'fileName': fileName,
            'isLocalFile': true,
            'fileUrl': fileUrl,
          };
        } else {
          throw Exception('Failed to download from Firebase: ${downloadResponse.statusCode}');
        }
      } else {
        throw Exception('Failed to get document info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading document: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getGroupStatistics(
    int groupId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/statistics/group/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      return {};
    }
  }

  // Obtener subjects populares para documentos
  static Future<List<Map<String, dynamic>>> getPopularSubjectsForDocuments(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/subjects/popular'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load popular subjects: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching popular subjects: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getGlobalStatistics(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.documentBase}/statistics/global'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load global statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching global statistics: $e');
      return {'totalDocuments': 0, 'myDocuments': 0, 'totalSize': 0};
    }
  }
}
