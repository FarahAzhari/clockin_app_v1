import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _userTokenKey = 'user_token';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';

  // Save token, username, and email
  Future<void> saveUserSession({
    required String token,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTokenKey, token);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTokenKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userTokenKey);
  }
}
