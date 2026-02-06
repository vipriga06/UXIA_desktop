import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Servicio de descubrimiento de servidor
class ServerDiscovery {
  static const _testEndpoint = '/api/users';
  static const _timeout = Duration(seconds: 3);

  /// Encuentra la URL correcta del servidor probando diferentes puertos
  static Future<String?> discoverServer(String urlBase) async {
    final uri = Uri.parse(urlBase);
    final baseUrl = '${uri.scheme}://${uri.host}';

    // Si ya tiene puerto específico, probarlo primero
    if (uri.hasPort) {
      if (await _testConnection(urlBase)) {
        return urlBase;
      }
    }

    // Probar puertos conocidos
    for (final port in AppConstants.defaultPorts) {
      final testUrl = '$baseUrl:$port';
      if (await _testConnection(testUrl)) {
        return testUrl;
      }
    }

    return null;
  }

  /// Prueba la conexión a un servidor
  static Future<bool> _testConnection(String url) async {
    try {
      if (kDebugMode) print('[Server Discovery] Intentando: $url');
      
      final response = await http
          .get(Uri.parse('$url$_testEndpoint'))
          .timeout(_timeout);

      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (success && kDebugMode) print('[Server Discovery] ✓ Conexión exitosa: $url');
      
      return success;
    } catch (e) {
      if (kDebugMode) print('[Server Discovery] ✗ Error en $url: $e');
      return false;
    }
  }
}
