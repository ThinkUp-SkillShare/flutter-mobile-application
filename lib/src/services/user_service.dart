import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const String keyUser = "user_data";

  // Save user
  static Future<void> saveUser(USER user) async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(user.toJson());
    await prefs.setString(keyUser, data);
  }

  // Get user
  static Future<USER?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(keyUser);
    if (data == null) return null;
    return USER.fromJson(jsonDecode(data));
  }

  // Deleted user
  static Future<void> deletedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUser);
  }
}
