import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import '../../domain/models/chats/chat_message.dart';

/// Service for handling chat operations including sending messages,
/// file uploads, reactions, and message management.
class ChatService {
  /// Fetches messages for a specific group with pagination support
  static Future<List<ChatMessage>> getMessages(
    int groupId,
    String token, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.chatMessages(groupId)}?page=$page&pageSize=$pageSize',
        ),
        headers: ApiConstants.headersWithToken(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }

      throw Exception('Failed to load messages: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  /// Sends a message to the group chat
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
      final body = {
        'messageType': messageType,
        if (content != null && content.isNotEmpty) 'content': content,
        if (fileBase64 != null && fileBase64.isNotEmpty)
          'fileBase64': fileBase64,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null && fileSize > 0) 'fileSize': fileSize,
        if (duration != null && duration > 0) 'duration': duration,
        if (replyToMessageId != null && replyToMessageId > 0)
          'replyToMessageId': replyToMessageId,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.chatMessages(groupId)),
        headers: ApiConstants.headersWithToken(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatMessage.fromJson(data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing message
  static Future<bool> updateMessage(
    int groupId,
    int messageId,
    String content,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.chatMessage(groupId, messageId)),
        headers: ApiConstants.headersWithToken(token),
        body: json.encode({'content': content}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Deletes a message
  static Future<bool> deleteMessage(
    int groupId,
    int messageId,
    String token,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.chatMessage(groupId, messageId)),
        headers: ApiConstants.headersWithToken(token),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Adds a reaction to a message
  static Future<bool> addReaction(
    int groupId,
    int messageId,
    String reaction,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatMessageReactions(groupId, messageId)),
        headers: ApiConstants.headersWithToken(token),
        body: json.encode({'reaction': reaction}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Marks a message as read
  static Future<bool> markAsRead(
    int groupId,
    int messageId,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.markMessageAsRead(groupId, messageId)),
        headers: ApiConstants.headersWithToken(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to send an image message
  static Future<ChatMessage?> sendImageMessage({
    required int groupId,
    required String token,
    required String imageBase64,
    required String fileName,
    required int fileSize,
    String? caption,
    int? replyToMessageId,
  }) async {
    return await sendMessage(
      groupId: groupId,
      token: token,
      messageType: 'image',
      content: caption,
      fileBase64: imageBase64,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToMessageId,
    );
  }

  /// Helper method to send an audio message
  static Future<ChatMessage?> sendAudioMessage({
    required int groupId,
    required String token,
    required String audioBase64,
    required String fileName,
    required int fileSize,
    required int duration,
    int? replyToMessageId,
  }) async {
    return await sendMessage(
      groupId: groupId,
      token: token,
      messageType: 'audio',
      fileBase64: audioBase64,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      replyToMessageId: replyToMessageId,
    );
  }

  /// Helper method to send a file message
  static Future<ChatMessage?> sendFileMessage({
    required int groupId,
    required String token,
    required String fileBase64,
    required String fileName,
    required int fileSize,
    String? description,
    int? replyToMessageId,
  }) async {
    return await sendMessage(
      groupId: groupId,
      token: token,
      messageType: 'file',
      content: description,
      fileBase64: fileBase64,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToMessageId,
    );
  }
}
