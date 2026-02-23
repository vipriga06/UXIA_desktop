import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';

/// Servicios API centralizados
class ApiService {
  final String baseUrl;
  final String token;
  final http.Client _httpClient;

  ApiService({
    required this.baseUrl,
    required this.token,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Headers por defecto
  Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Realiza una petición GET
  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) debugPrint('[GET] $url');

      return await _httpClient
          .get(url, headers: _defaultHeaders())
          .timeout(const Duration(seconds: AppConstants.timeoutSeconds));
    } catch (e) {
      if (kDebugMode) debugPrint('[GET ERROR] $e');
      rethrow;
    }
  }

  /// Realiza una petición POST
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) debugPrint('[POST] $url with body: $body');

      return await _httpClient
          .post(url, headers: _defaultHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: AppConstants.timeoutSeconds));
    } catch (e) {
      if (kDebugMode) debugPrint('[POST ERROR] $e');
      rethrow;
    }
  }

  /// Realiza una petición PATCH
  Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) debugPrint('[PATCH] $url with body: $body');

      return await _httpClient
          .patch(url, headers: _defaultHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: AppConstants.timeoutSeconds));
    } catch (e) {
      if (kDebugMode) debugPrint('[PATCH ERROR] $e');
      rethrow;
    }
  }

  /// Realiza una petición DELETE
  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) debugPrint('[DELETE] $url');

      return await _httpClient
          .delete(url, headers: _defaultHeaders())
          .timeout(const Duration(seconds: AppConstants.timeoutSeconds));
    } catch (e) {
      if (kDebugMode) debugPrint('[DELETE ERROR] $e');
      rethrow;
    }
  }

  /// Obtiene el usuario autenticado
  Future<AuthUser?> getAuthUser() async {
    try {
      final response = await get(
        '${AppConstants.apiPath}${AppConstants.adminPath}/testtoken',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] != null) {
          return AuthUser.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting auth user: $e');
      return null;
    }
  }

  /// Obtiene lista de usuarios
  Future<List<User>> getUsers() async {
    try {
      final response = await get(
        '${AppConstants.apiPath}${AppConstants.adminPath}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] is List) {
          return (data['data'] as List)
              .map((u) => User.fromJson(u as Map<String, dynamic>))
              .where((user) => user.id.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting users: $e');
      rethrow;
    }
  }

  /// Crea un nuevo usuario
  Future<User?> createUser({
    required String email,
    required String nickname,
    required String password,
    required String telefon,
  }) async {
    try {
      // Generar una contraseña aleatoria si no se proporciona
      final password = 'UxIa${DateTime.now().millisecondsSinceEpoch}';
      final response = await post(
        '${AppConstants.apiPath}${AppConstants.adminPath}',
        body: {
          'email': email,
          'nickname': nickname,
          'password': password,
          'telefon': telefon,
          'role': 'user',
          'validat': true,
          'tos': true,
        },
      );

      if (kDebugMode) {
        debugPrint('[CREATE USER] status: ${response.statusCode} body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] != null) {
          final user = User.fromJson(data['data'] as Map<String, dynamic>);
          if (user.id.isEmpty) {
            if (kDebugMode) {
              debugPrint('Error: el backend devolvió id vacío al crear usuario.');
            }
            throw Exception('Error: el backend devolvió id vacío al crear usuario.');
          }
          return user;
        }
      } else {
        if (kDebugMode) {
          debugPrint('[CREATE USER ERROR] status: ${response.statusCode} body: ${response.body}');
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  /// Elimina un usuario
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await delete(
        '${AppConstants.apiPath}${AppConstants.adminPath}/$userId',
      );
      if (kDebugMode) {
        debugPrint(
          'DELETE user $userId response: ${response.statusCode} ${response.body}',
        );
      }
      if (response.statusCode == 200) {
        // Comprobar que el usuario realmente no está en la lista tras borrar
        final usersResponse = await getUsers();
        final exists = usersResponse.any((u) => u.id == userId);
        if (exists) {
          if (kDebugMode) {
            debugPrint('Usuario $userId sigue existiendo tras borrar.');
          }
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  /// Actualiza el rol de un usuario
  Future<User?> updateUserRole(String userId, String newRole) async {
    try {
      final response = await patch(
        '${AppConstants.apiPath}${AppConstants.adminPath}/$userId/rol',
        body: {'role': newRole},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] != null) {
          return User.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
