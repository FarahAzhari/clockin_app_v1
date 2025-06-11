// auth_controller.dart
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/user_model.dart'; // Import UserModel
import 'package:clockin_app/data/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final SessionManager _session = SessionManager();

  Future<bool> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user != null) {
      // Save all relevant user details to session
      await _session.saveUserSession(
        userId: user.id, // Save userId
        token: user.id.toString(), // or use an actual token if you have one
        username: user.username,
        email: user.email,
        mobileNo: user.mobileNo, // Save mobileNo
        dob: user.dob, // Save dob
        bloodGroup: user.bloodGroup, // Save bloodGroup
        designation: user.designation, // Save designation
        joinedDate: user.joinedDate, // Save joinedDate
        profileImageUrl: user.profileImageUrl, // Save profileImageUrl
      );
      return true;
    }
    return false;
  }

  Future<bool> register(UserModel user) async {
    // You might want to hash the password before registering in a real app
    final userId = await _authService.register(user);
    return userId != 0;
  }

  Future<bool> isLoggedIn() => _session.isLoggedIn();

  // NEW METHOD: Get the full current user model from session manager or service
  Future<UserModel?> getCurrentUser() async {
    final userId = await _session
        .getUserIdAsInt(); // Assuming getUserIdAsInt exists
    if (userId != null) {
      // Try to fetch from service for the most up-to-date info
      final user = await _authService.getUserById(userId);
      // If service fails or user not found there, try to reconstruct from session
      if (user == null) {
        return UserModel(
          id: userId,
          username: await _session.getUsername() ?? 'Unknown',
          email: await _session.getEmail() ?? 'unknown@example.com',
          password: '', // Password is not stored in session
          // FIX: Explicitly add the 'role' parameter. Assuming a default 'user' role
          // if not fetched from a more authoritative source (like the database).
          role: 'user', // Provide a default role
          mobileNo: await _session.getMobileNo(),
          dob: await _session.getDob(),
          bloodGroup: await _session.getBloodGroup(),
          designation: await _session.getDesignation(),
          joinedDate: await _session.getJoinedDate(),
          profileImageUrl: await _session.getProfileImageUrl(),
        );
      }
      return user;
    }
    return null; // No user logged in
  }

  // Optional: Update user details via controller
  Future<bool> updateCurrentUserDetails(UserModel updatedUser) async {
    final userId = await _session.getUserIdAsInt();
    if (userId == null || updatedUser.id != userId) {
      print(
        'Error: Attempting to update a user different from the logged-in user.',
      );
      return false;
    }
    final success = await _authService.updateUserDetails(updatedUser);
    if (success > 0) {
      // If update successful, refresh session manager with new data
      await _session.saveUserSession(
        userId: updatedUser.id,
        token: updatedUser.id.toString(),
        username: updatedUser.username,
        email: updatedUser.email,
        mobileNo: updatedUser.mobileNo,
        dob: updatedUser.dob,
        bloodGroup: updatedUser.bloodGroup,
        designation: updatedUser.designation,
        joinedDate: updatedUser.joinedDate,
        profileImageUrl: updatedUser.profileImageUrl,
      );
      return true;
    }
    return false;
  }
}
