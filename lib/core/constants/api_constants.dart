/// Contains all API endpoints and configuration for the application.
/// Centralizes URL construction to ensure consistency and easy maintenance.
class ApiConstants {
  /// Base URL for all API requests
  static const String baseUrl = 'https://skillshare-flutter-backend.onrender.com/api';

  static const String wsBaseUrl = 'skillshare-flutter-backend.onrender.com';

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
  static String studyGroupsByUserId(int userId) => '$studyGroupBase/user/$userId';
  static String recentGroups(int userId) => '$studyGroupBase/recent?userId=$userId';
  static String studyGroupById(int id, {int? userId}) =>
      userId != null ? '$studyGroupBase/$id?userId=$userId' : '$studyGroupBase/$id';
  static String joinGroup(int groupId) => '$studyGroupBase/$groupId/join';
  static String leaveGroup(int groupId) => '$studyGroupBase/$groupId/leave';
  static String groupMembers(int groupId) => '$studyGroupBase/$groupId/members';

  // Group management endpoints
  static String groupPermissions(int groupId) => '$studyGroupBase/$groupId/permissions';
  static String groupStatistics(int groupId) => '$studyGroupBase/$groupId/statistics';

  // Subject endpoints
  static String get subjectBase => '$baseUrl/Subject';
  static String subjectById(int id) => '$subjectBase/$id';

  // Document endpoints
  static final String documentBase = '$baseUrl/document';
  static String groupDocuments(int groupId) => '$documentBase/group/$groupId';
  static String userDocuments = '$documentBase/user';
  static String documentUpload = '$documentBase/upload';
  static String documentById(int documentId) => '$documentBase/$documentId';
  static String documentDownload(int documentId) => '$documentBase/$documentId/download';
  static String documentStatisticsGroup(int groupId) => '$documentBase/statistics/group/$groupId';
  static String popularSubjectsForDocuments = '$documentBase/subjects/popular';

  /// Standard headers for API requests without authentication
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Headers for authenticated API requests with Bearer token
  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}