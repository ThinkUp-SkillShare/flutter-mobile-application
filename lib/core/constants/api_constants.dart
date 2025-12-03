/// Contains all API endpoints and configuration for the application.
/// Centralizes URL construction to ensure consistency and easy maintenance.
class ApiConstants {
  /// Base URL for all API requests
  static const String baseUrl =
      'https://skillshare-flutter-backend.onrender.com/api';

  static const String wsBaseUrl = 'skillshare-flutter-backend.onrender.com';

  static const String fileBaseUrl =
      'https://skillshare-flutter-backend.onrender.com';

  // Auth endpoints
  static final String loginEndpoint = '$baseUrl/Auth/login';
  static final String registerEndpoint = '$baseUrl/Auth/register';
  static final String validateTokenEndpoint = '$baseUrl/Auth/validate-token';

  // Student endpoints
  static String get studentBase => '$baseUrl/student';

  static String studentByUserId(int userId) => '$studentBase/user/$userId';

  static String studentById(int id) => '$studentBase/$id';

  // StudyGroup endpoints
  static String get studyGroupBase => '$baseUrl/StudyGroup';

  static String studyGroupsByUserId(int userId) =>
      '$studyGroupBase/user/$userId';

  static String recentGroups(int userId) =>
      '$studyGroupBase/recent?userId=$userId';

  static String studyGroupById(int id, {int? userId}) => userId != null
      ? '$studyGroupBase/$id?userId=$userId'
      : '$studyGroupBase/$id';

  static String joinGroup(int groupId) => '$studyGroupBase/$groupId/join';

  static String leaveGroup(int groupId) => '$studyGroupBase/$groupId/leave';

  static String groupMembers(int groupId) => '$studyGroupBase/$groupId/members';

  // Group management endpoints
  static String groupPermissions(int groupId) =>
      '$studyGroupBase/$groupId/permissions';

  static String groupStatistics(int groupId) =>
      '$studyGroupBase/$groupId/statistics';

  // Subject endpoints
  static String get subjectBase => '$baseUrl/Subject';

  static String subjectById(int id) => '$subjectBase/$id';

  // Document endpoints
  static final String documentBase = '$baseUrl/document';

  static String groupDocuments(int groupId) => '$documentBase/group/$groupId';
  static String userDocuments = '$documentBase/user';
  static String documentUpload = '$documentBase/upload';

  static String documentById(int documentId) => '$documentBase/$documentId';

  static String documentDownload(int documentId) =>
      '$documentBase/$documentId/download';

  static String documentStatisticsGroup(int groupId) =>
      '$documentBase/statistics/group/$groupId';
  static String popularSubjectsForDocuments = '$documentBase/subjects/popular';

  // Chat endpoints
  static String get chatBase => '$baseUrl/groups';

  static String chatMessages(int groupId) => '$chatBase/$groupId/chat/messages';

  static String chatMessage(int groupId, int messageId) =>
      '$chatBase/$groupId/chat/messages/$messageId';

  static String chatMessageReactions(int groupId, int messageId) =>
      '$chatBase/$groupId/chat/messages/$messageId/reactions';

  static String markMessageAsRead(int groupId, int messageId) =>
      '$chatBase/$groupId/chat/messages/$messageId/read';

  // WebSocket chat endpoint
  static String webSocketChat(int groupId) =>
      'wss://$wsBaseUrl/ws/chat/$groupId';

  // File upload endpoints
  static String get uploadBase => '$fileBaseUrl/uploads';

  static String audioUploadUrl(String fileName) =>
      '$uploadBase/audio/$fileName';

  static String imageUploadUrl(String fileName) =>
      '$uploadBase/images/$fileName';

  static String documentUploadUrl(String fileName) =>
      '$uploadBase/documents/$fileName';

  // Call endpoints
  static String get callBase => '$baseUrl/Calls';

  static String callHistory(int groupId) => '$callBase/call-history/$groupId';
  static String createCallRoom = '$callBase/create-room';
  static String joinCallEndpoint = '$callBase/join-call';
  static String endCallEndpoint = '$callBase/end-call';
  static String getCallTokenEndpoint = '$callBase/get-token';

  static String callStats(int groupId) => '$callBase/call-stats/$groupId';
  static String userCallStats = '$callBase/user-stats';

  static String activeCall(int groupId) => '$callBase/active-call/$groupId';

  // WebSocket endpoints
  static String webSocketCall(String callId, String userId) =>
      'wss://$wsBaseUrl/ws/call/$callId?userId=$userId';

  /// Standard headers for API requests without authentication
  static Map<String, String> get headers {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// Headers for authenticated API requests with Bearer token
  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Helper method to build complete file URLs
  static String buildFileUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';

    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    if (filePath.startsWith('data:')) {
      return filePath;
    }

    return '$fileBaseUrl/uploads/images/$filePath';
  }

  /// Helper method to build document file URLs
  static String buildDocumentUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';

    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    return '$fileBaseUrl/uploads/documents/$filePath';
  }

  /// Helper method to build audio file URLs
  static String buildAudioUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';

    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    if (filePath.startsWith('data:')) {
      return filePath;
    }

    return '$fileBaseUrl/uploads/audio/$filePath';
  }
}
