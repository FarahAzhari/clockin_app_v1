// (optional) or you can use bloc/provider
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/user_model.dart';
import 'package:clockin_app/data/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final SessionManager _session = SessionManager();

  Future<bool> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user != null) {
      await _session.saveUserSession(
        token: user.id.toString(), // or use an actual token if you have one
        username: user.username,
        email: user.email,
      );
      return true;
    }
    return false;
  }

  Future<bool> register(UserModel user) async {
    final userId = await _authService.register(user);
    return userId != 0;
  }

  Future<bool> isLoggedIn() => _session.isLoggedIn();
}
