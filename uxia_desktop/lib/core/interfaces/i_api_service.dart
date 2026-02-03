import '../../models/user_model.dart';

/// Interface para servicio de API (Dependency Inversion Principle)
abstract class IApiService {
  /// Establece la URL base del servidor
  void setBaseUrl(String url);

  /// Establece el token de autenticación
  void setToken(String token);

  /// Realiza login con credenciales reales
  Future<User> login(String username, String password);

  /// Realiza login simulado para desarrollo
  Future<User> loginSimulated(String username, String password);
}
