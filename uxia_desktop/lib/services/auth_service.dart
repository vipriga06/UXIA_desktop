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
    // TODO: Implementar llamada real al servidor
    await Future.delayed(const Duration(seconds: 1));

    // Simulación
    return User(
      id: '1',
      username: username,
      email: '$username@example.com',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      loginTime: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    // TODO: Implementar limpieza de sesión
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Verificar token válido
    return false;
  }
}
