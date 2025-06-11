import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  // Keys for additional profile fields
  static const _mobileNoKey = 'mobileNo';
  static const _dobKey = 'dob';
  static const _bloodGroupKey = 'bloodGroup';
  static const _designationKey = 'designation';
  static const _joinedDateKey = 'joinedDate';
  static const _profileImageUrlKey = 'profileImageUrl';

  // Save user session details. The userId will be stored as an int.
  // The 'token' parameter was originally used to pass user.id.toString(),
  // but now we explicitly use 'userId' (int) for _userIdKey.
  Future<void> saveUserSession({
    int? userId, // The actual integer user ID
    required String
    token, // This token is often user.id.toString() from AuthController
    required String username,
    required String email,
    String? mobileNo,
    String? dob,
    String? bloodGroup,
    String? designation,
    String? joinedDate,
    String? profileImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // FIX: Consistently store the userId as an int using setInt for _userIdKey.
    // If userId is null (e.g., during logout or initial state), ensure the key is removed.
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    } else {
      await prefs.remove(_userIdKey); // Remove if no valid userId to store
    }

    // The 'token' parameter (which is typically just the string representation of userId)
    // is now implicitly handled by storing userId as an int. If you truly need a separate
    // string token (like a JWT), you'd need a different static key for it.
    // For now, we omit storing the 'token' string directly if it's the same as userId.toString().

    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);

    // Save additional profile fields if not null
    if (mobileNo != null) await prefs.setString(_mobileNoKey, mobileNo);
    if (dob != null) await prefs.setString(_dobKey, dob);
    if (bloodGroup != null) await prefs.setString(_bloodGroupKey, bloodGroup);
    if (designation != null)
      await prefs.setString(_designationKey, designation);
    if (joinedDate != null) await prefs.setString(_joinedDateKey, joinedDate);
    if (profileImageUrl != null)
      await prefs.setString(_profileImageUrlKey, profileImageUrl);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // This method is now problematic as _userIdKey stores int.
    // It's recommended to use getUserIdAsInt() instead.
    // For backward compatibility, you *could* try to fetch as int and convert to string,
    // but better to refactor callers to use getUserIdAsInt.
    final idInt = prefs.getInt(_userIdKey);
    return idInt?.toString();
  }

  Future<int?> getUserIdAsInt() async {
    final prefs = await SharedPreferences.getInstance();
    // FIX: Directly get the integer from SharedPreferences using getInt().
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Getters for additional profile fields
  Future<String?> getMobileNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileNoKey);
  }

  Future<String?> getDob() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dobKey);
  }

  Future<String?> getBloodGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bloodGroupKey);
  }

  Future<String?> getDesignation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_designationKey);
  }

  Future<String?> getJoinedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_joinedDateKey);
  }

  Future<String?> getProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageUrlKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    // Clear additional profile fields on logout
    await prefs.remove(_mobileNoKey);
    await prefs.remove(_dobKey);
    await prefs.remove(_bloodGroupKey);
    await prefs.remove(_designationKey);
    await prefs.remove(_joinedDateKey);
    await prefs.remove(_profileImageUrlKey);
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if the user ID key exists to determine if logged in
    // This will check if an integer is stored for _userIdKey.
    return prefs.containsKey(_userIdKey);
  }
}
