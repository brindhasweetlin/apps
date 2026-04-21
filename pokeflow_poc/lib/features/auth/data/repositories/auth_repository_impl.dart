import '../../../../core/security/security_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecurityService _securityService;

  AuthRepositoryImpl(this._securityService);

  @override
  Future<User?> login(String email, String password) async {
    if (email == 'user@example.com' && password == 'password') {
      const token = 'mock_jwt_token';
      await _securityService.saveToken(token);
      return User(id: '1', email: email, token: token);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _securityService.clearSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _securityService.getToken();
    return token != null && token.isNotEmpty;
  }
}
