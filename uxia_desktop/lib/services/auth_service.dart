import 'package:uxia_desktop/models/user_model.dart';

abstract class IAuthService {
  Future<User?> login(String urlServidor, String username, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
}

class AuthService implements IAuthService {
  @override
  Future<User?> login(
    String urlServidor,
    String username,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Cridar API real del servidor
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Netejar sessió
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Verificar token
    return false;
  }
}
