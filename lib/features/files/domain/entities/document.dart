import 'package:equatable/equatable.dart';

/// Domain entity representing a document
class Document extends Equatable {
  final int id;
  final int groupId;
  final String? groupName;
  final int userId;
  final String userEmail;
  final String title;
  final String? description;
  final String fileName;
  final String fileUrl;
  final int? fileSize;
  final String? fileType;
  final int? subjectId;
  final String? subjectName;
  final DateTime uploadDate;
  final int downloadCount;
  final int favoriteCount;
  final bool isFavorite;

  const Document({
    required this.id,
    required this.groupId,
    this.groupName,
    required this.userId,
    required this.userEmail,
    required this.title,
    this.description,
    required this.fileName,
    required this.fileUrl,
    this.fileSize,
    this.fileType,
    this.subjectId,
    this.subjectName,
    required this.uploadDate,
    this.downloadCount = 0,
    this.favoriteCount = 0,
    this.isFavorite = false,
  });

  /// Creates a Document from JSON data
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      groupName: json['groupName'] as String?,
      userId: json['userId'] as int,
      userEmail: json['userEmail'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as int?,
      fileType: json['fileType'] as String?,
      subjectId: json['subjectId'] as int?,
      subjectName: json['subjectName'] as String?,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      downloadCount: json['downloadCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Converts Document to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'userId': userId,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileType': fileType,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'uploadDate': uploadDate.toIso8601String(),
      'downloadCount': downloadCount,
      'favoriteCount': favoriteCount,
      'isFavorite': isFavorite,
    };
  }

  /// Creates a copy with updated values
  Document copyWith({
    int? id,
    int? groupId,
    String? groupName,
    int? userId,
    String? userEmail,
    String? title,
    String? description,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? fileType,
    int? subjectId,
    String? subjectName,
    DateTime? uploadDate,
    int? downloadCount,
    int? favoriteCount,
    bool? isFavorite,
  }) {
    return Document(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      uploadDate: uploadDate ?? this.uploadDate,
      downloadCount: downloadCount ?? this.downloadCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    groupId,
    userId,
    title,
    fileName,
    uploadDate,
  ];
}