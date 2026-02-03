import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class ApiService {
  late String baseUrl;
  String? _token;

  ApiService();

  void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url : '$url/';
  }

  void setToken(String token) {
    _token = token;
  }

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

  // Simulación de datos para desarrollo local
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
