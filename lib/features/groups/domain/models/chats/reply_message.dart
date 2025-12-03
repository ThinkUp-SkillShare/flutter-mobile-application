class ReplyMessage {
  final int id;
  final int userId;
  final String userEmail;
  final String messageType;
  final String? content;
  final String? fileName;

  ReplyMessage({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.messageType,
    this.content,
    this.fileName,
  });

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      id: json['id'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      messageType: json['messageType'],
      content: json['content'],
      fileName: json['fileName'],
    );
  }
}