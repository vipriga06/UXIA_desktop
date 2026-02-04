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
    // Mientras tanto, simular que todos los usuarios son inválidos
    await Future.delayed(const Duration(seconds: 1));

    // Retornar null para indicar que el login falló
    return null;
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
