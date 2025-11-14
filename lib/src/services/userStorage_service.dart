import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class UserStorage {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/users.json");
  }

  static Future<List<USER>> getUsers() async {
    try {
      final file = await _getFile();
      if (!(await file.exists())) {
        return [];
      }
      String content = await file.readAsString();
      List<dynamic> data = jsonDecode(content);
      return data.map((e) => USER.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveUser(USER user) async {
    final users = await getUsers();
    users.add(user);

    final file = await _getFile();
    String jsonData = jsonEncode(users.map((u) => u.toJson()).toList());
    await file.writeAsString(jsonData);
  }
}
