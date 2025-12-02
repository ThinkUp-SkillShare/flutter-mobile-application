import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/chat_message.dart';

class ChatService {
  static get baseUrl => ApiConstants.baseUrl;

  static Future<List<ChatMessage>> getMessages(
      int groupId,
      String token, {
        int page = 1,
        int pageSize = 50,
      }) async {
    try {
      final url = Uri.parse('$baseUrl/groups/$groupId/chat/messages?page=$page&pageSize=$pageSize');

      print('🔍 GET Messages - URL: $url');
      print('🔍 GET Messages - GroupId: $groupId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 GET Messages - Response Status: ${response.statusCode}');
      print('🔍 GET Messages - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('🔍 GET Messages - Parsed ${data.length} messages');
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        print('❌ GET Messages - Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ GET Messages - Exception: $e');
      throw Exception('Error getting messages: $e');
    }
  }

  /// Enviar un mensaje de texto
  static Future<ChatMessage?> sendMessage({
    required int groupId,
    required String token,
    required String messageType,
    String? content,
    String? fileBase64,
    String? fileName,
    int? fileSize,
    int? duration,
    int? replyToMessageId,
  }) async {
    try {
      // CORREGIDO: Quitar el "api/" extra
      final url = Uri.parse('$baseUrl/groups/$groupId/chat/messages');

      print('📤 SEND Message - URL: $url');
      print('📤 SEND Message - GroupId: $groupId');
      print('📤 SEND Message - Type: $messageType');
      print('📤 SEND Message - Content: $content');

      final body = {
        'messageType': messageType,
        if (content != null) 'content': content,
        if (fileBase64 != null) 'fileBase64': fileBase64,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        if (duration != null) 'duration': duration,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      };

      print('📤 SEND Message - Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📤 SEND Message - Response Status: ${response.statusCode}');
      print('📤 SEND Message - Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ SEND Message - Success, Message ID: ${data['id']}');
        return ChatMessage.fromJson(data);
      } else {
        print('❌ SEND Message - Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SEND Message - Exception: $e');
      return null;
    }
  }

  /// Actualizar un mensaje
  static Future<bool> updateMessage(
      int groupId,
      int messageId,
      String content,
      String token,
      ) async {
    try {
      final url = Uri.parse('$baseUrl/groups/$groupId/chat/messages/$messageId');

      print('✏️ UPDATE Message - URL: $url');
      print('✏️ UPDATE Message - Content: $content');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      print('✏️ UPDATE Message - Response Status: ${response.statusCode}');

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('❌ UPDATE Message - Exception: $e');
      return false;
    }
  }

  static Future<ChatMessage?> sendAudioMessage({
    required int groupId,
    required String token,
    required String fileBase64,
    required String fileName,
    required int fileSize,
    required int duration,
    String? content,
  }) async {
    return await sendMessage(
      groupId: groupId,
      token: token,
      messageType: 'audio',
      fileBase64: fileBase64,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      content: content,
    );
  }

  /// Eliminar un mensaje
  static Future<bool> deleteMessage(
      int groupId,
      int messageId,
      String token,
      ) async {
    try {
      // CORREGIDO: Quitar el "api/" extra
      final url = Uri.parse('$baseUrl/groups/$groupId/chat/messages/$messageId');

      print('🗑️ DELETE Message - URL: $url');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🗑️ DELETE Message - Response Status: ${response.statusCode}');

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('❌ DELETE Message - Exception: $e');
      return false;
    }
  }

  /// Agregar una reacción a un mensaje
  static Future<bool> addReaction(
      int groupId,
      int messageId,
      String reaction,
      String token,
      ) async {
    try {
      // CORREGIDO: Quitar el "api/" extra
      final url = Uri.parse('$baseUrl/groups/$groupId/chat/messages/$messageId/reactions');

      print('❤️ ADD Reaction - URL: $url');
      print('❤️ ADD Reaction - Reaction: $reaction');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reaction': reaction}),
      );

      print('❤️ ADD Reaction - Response Status: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ ADD Reaction - Exception: $e');
      return false;
    }
  }

  /// Marcar mensaje como leído
  static Future<bool> markAsRead(
      int groupId,
      int messageId,
      String token,
      ) async {
    try {
      // CORREGIDO: Quitar el "api/" extra
      final url = Uri.parse('$baseUrl/groups/$groupId/chat/messages/$messageId/read');

      print('👀 MARK AS READ - URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('👀 MARK AS READ - Response Status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ MARK AS READ - Exception: $e');
      return false;
    }
  }

  /// Convertir archivo a Base64
  static Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      print('📄 FILE to Base64 - File: ${file.path}');
      print('📄 FILE to Base64 - Size: ${bytes.length} bytes');
      return base64String;
    } catch (e) {
      print('❌ FILE to Base64 - Exception: $e');
      throw Exception('Error converting file to base64: $e');
    }
  }

  /// Obtener el tipo MIME de un archivo
  static String getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/mp4';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }

  /// Crear string Base64 con data URL prefix
  static String createDataUrl(String base64, String fileName) {
    final mimeType = getMimeType(fileName);
    final dataUrl = 'data:$mimeType;base64,$base64';
    print('🔗 CREATE Data URL - MIME: $mimeType');
    return dataUrl;
  }
}