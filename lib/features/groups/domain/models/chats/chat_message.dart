import 'package:skillshare/features/groups/domain/models/chats/reply_message.dart';

import 'message_reaction.dart';

class ChatMessage {
  final int id;
  final int groupId;
  final int userId;
  final String userEmail;
  final String? userProfileImage;
  final String messageType;
  final String? content;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final int? duration;
  final int? replyToMessageId;
  final ReplyMessage? replyToMessage;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MessageReaction> reactions;
  final bool isRead;
  final bool isSentByCurrentUser;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userEmail,
    this.userProfileImage,
    required this.messageType,
    this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    this.replyToMessageId,
    this.replyToMessage,
    required this.isEdited,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.reactions,
    required this.isRead,
    required this.isSentByCurrentUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      userProfileImage: json['userProfileImage'],
      messageType: json['messageType'],
      content: json['content'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      duration: json['duration'],
      replyToMessageId: json['replyToMessageId'],
      replyToMessage: json['replyToMessage'] != null
          ? ReplyMessage.fromJson(json['replyToMessage'])
          : null,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ??
          [],
      isRead: json['isRead'] ?? false,
      isSentByCurrentUser: json['isSentByCurrentUser'] ?? false,
    );
  }
}