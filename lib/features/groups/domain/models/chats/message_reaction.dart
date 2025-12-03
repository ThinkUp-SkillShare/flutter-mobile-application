class MessageReaction {
  final int id;
  final int messageId;
  final int userId;
  final String userEmail;
  final String reaction;
  final DateTime createdAt;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.userEmail,
    required this.reaction,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      id: json['id'],
      messageId: json['messageId'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      reaction: json['reaction'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}