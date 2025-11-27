class ApiConstants {
  static const bool isEmulator = false;

  static String get baseUrl {
    if (isEmulator) {
      return 'http://10.0.2.2:5118/api';
    } else {
      return 'http://192.168.0.206:5118/api';
    }
  }

  static final String loginEndpoint = '$baseUrl/Auth/login';
  static final String registerEndpoint = '$baseUrl/Auth/register';
  static final String validateTokenEndpoint = '$baseUrl/Auth/validate-token';
  static final String testConnectionEndpoint = '$baseUrl/Auth/test-connection';

  static String get studentBase => '$baseUrl/student';
  static String userBase = '$baseUrl/users';
  static String studentByUserId(int userId) => '$studentBase/user/$userId';
  static String studentById(int id) => '$studentBase/$id';

  static String get studyGroupBase => '$baseUrl/StudyGroup';
  static String studyGroupsByUserId(int userId) => '$studyGroupBase/user/$userId';
  static String recentGroups(int userId) => '$studyGroupBase/recent?userId=$userId';
  static String studyGroupById(int id, {int? userId}) =>
      userId != null ? '$studyGroupBase/$id?userId=$userId' : '$studyGroupBase/$id';
  static String joinGroup(int groupId) => '$studyGroupBase/$groupId/join';
  static String leaveGroup(int groupId) => '$studyGroupBase/$groupId/leave';
  static String groupMembers(int groupId) => '$studyGroupBase/$groupId/members';

  static String get subjectBase => '$baseUrl/Subject';
  static String subjectById(int id) => '$subjectBase/$id';

  static String groupChat(int groupId) => '$studyGroupBase/$groupId/chat/messages';
  static String groupChatMessage(int groupId, int messageId) =>
      '$studyGroupBase/$groupId/chat/messages/$messageId';
  static String messageReactions(int groupId, int messageId) =>
      '$studyGroupBase/$groupId/chat/messages/$messageId/reactions';
  static String messageReaction(int groupId, int messageId, int reactionId) =>
      '$studyGroupBase/$groupId/chat/messages/$messageId/reactions/$reactionId';
  static String markMessageAsRead(int groupId, int messageId) =>
      '$studyGroupBase/$groupId/chat/messages/$messageId/read';

  static String groupPermissions(int groupId) => '$studyGroupBase/$groupId/permissions';
  static String groupStatistics(int groupId) => '$studyGroupBase/$groupId/statistics';
  static String promoteToAdmin(int groupId, int memberId) => '$studyGroupBase/$groupId/members/$memberId/promote';
  static String demoteToMember(int groupId, int memberId) => '$studyGroupBase/$groupId/members/$memberId/demote';
  static String removeMember(int groupId, int memberId) => '$studyGroupBase/$groupId/members/$memberId';
  static String bulkRemoveMembers(int groupId) => '$studyGroupBase/$groupId/members/bulk-remove';
  static String transferOwnership(int groupId) => '$studyGroupBase/$groupId/transfer-ownership';
}
