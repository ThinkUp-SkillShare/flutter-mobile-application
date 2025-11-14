import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../domain/models/chat_message.dart';

class ChatService {
  static Future<List<ChatMessage>> getMessages(
      int groupId,
      String token, {
        int page = 1,
        int pageSize = 50,
      }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.studyGroupBase}/$groupId/chat/messages?page=$page&pageSize=$pageSize',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((msg) => ChatMessage.fromJson(msg)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  static Future<ChatMessage?> sendMessage({
    required int groupId,
    required String token,
    required String messageType,
    String? content,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    int? duration,
    int? replyToMessageId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/chat/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'groupId': groupId,
          'messageType': messageType,
          'content': content,
          'fileUrl': fileUrl,
          'fileName': fileName,
          'fileSize': fileSize,
          'duration': duration,
          'replyToMessageId': replyToMessageId,
        }),
      );

      if (response.statusCode == 201) {
        return ChatMessage.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  static Future<bool> updateMessage(
      int groupId,
      int messageId,
      String content,
      String token,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/chat/messages/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error updating message: $e');
      return false;
    }
  }

  static Future<bool> deleteMessage(
      int groupId,
      int messageId,
      String token,
      ) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/chat/messages/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  static Future<bool> addReaction(
      int groupId,
      int messageId,
      String reaction,
      String token,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/chat/messages/$messageId/reactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reaction': reaction}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding reaction: $e');
      return false;
    }
  }

  static Future<bool> removeReaction(
      int groupId,
      int messageId,
      int reactionId,
      String token,
      ) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/chat/messages/$messageId/reactions/$reactionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error removing reaction: $e');
      return false;
    }
  }

  static Future<bool> markAsRead(
      int groupId,
      int messageId,
      String token,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/chat/messages/$messageId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }
}