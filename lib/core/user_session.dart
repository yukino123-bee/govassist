import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/service_data.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  Map<String, dynamic>? currentUser;

  Future<void> setUser(Map<String, dynamic> user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user', json.encode(user));
  }

  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUserString = prefs.getString('cached_user');
    final cachedToken = prefs.getString('auth_token');
    
    if (cachedUserString != null && cachedToken != null) {
      currentUser = json.decode(cachedUserString);
      ServiceData.setToken(cachedToken);
      return true;
    }
    return false;
  }

  Future<void> clearSession() async {
    currentUser = null;
    ServiceData.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
    await prefs.remove('auth_token');
  }
}
