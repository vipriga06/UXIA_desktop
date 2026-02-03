import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../core/interfaces/i_api_service.dart';

/// Implementación del servicio de API (Single Responsibility Principle)
class ApiService implements IApiService {
  late String baseUrl;
  String? _token;

  ApiService();

  @override
  void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url : '$url/';
  }

  @override
  void setToken(String token) {
    _token = token;
  }

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/admin/usuaris/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Login fallido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<User> loginSimulated(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    // Validación simple para demo
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Usuario o contraseña vacíos');
    }

    return User(
      id: '1',
      username: username,
      email: '$username@example.com',
      token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
      loginTime: DateTime.now(),
    );
  }
}
