import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'settings_manager.dart';

/// Servicio de autenticación
class AuthService {
  final SettingsManager settingsManager;
  final http.Client _httpClient;

  AuthService({required this.settingsManager, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Realiza login de administrador
  Future<({String message, bool success, String? token})> loginAdmin({
    required String urlBase,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '$urlBase${AppConstants.apiPath}${AppConstants.adminPath}/login',
      );
      if (kDebugMode) debugPrint('[Auth] Login attempt to: $url');

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: AppConstants.timeoutSeconds));

      if (response.body.isEmpty) {
        return (
          success: false,
          token: null,
          message: 'Resposta buida del servidor',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] == 'OK') {
        final token = data['data']?['token'] as String?;
        final msg = (data['message'] as String?) ?? '';
        return (success: true, token: token, message: msg);
      }

      final msg = (data['message'] as String?) ?? 'Error de resposta';
      return (success: false, token: null, message: msg);
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] Login error: $e');
      return (success: false, token: null, message: 'Error de connexió: $e');
    }
  }

  /// Obtiene el email de un usuario por su nickname
  Future<String?> getEmailFromUsername(String baseUrl, String username) async {
    try {
      final url = Uri.parse('$baseUrl${AppConstants.apiPath}/users');
      final response = await _httpClient.get(url);

      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final data = jsonDecode(response.body);
      if (data is List) {
        for (final item in data) {
          if (item is Map && item['nickname'] == username) {
            return item['email'] as String?;
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] Error getting email: $e');
      return null;
    }
  }

  /// Realiza logout
  Future<bool> logout(String baseUrl, String token) async {
    try {
      final url = Uri.parse(
        '$baseUrl${AppConstants.apiPath}${AppConstants.adminPath}/logout',
      );
      const timeout = Duration(seconds: AppConstants.timeoutSeconds);

      final response = await _httpClient
          .post(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] Logout error: $e');
      return false;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
