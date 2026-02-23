import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio de descubrimiento de servidor
class ServerDiscovery {
  static const _testEndpoint = '/health';
  static const _timeout = Duration(milliseconds: 1500);

  /// Encuentra la URL correcta del servidor probando diferentes puertos
  static Future<String?> discoverServer(String urlBase) async {
    // Validar que la URL no esté vacía ni mal formada
    if (urlBase.trim().isEmpty) {
      if (kDebugMode) debugPrint('[Server Discovery] ✗ URL vacía');
      return null;
    }
    String cleanUrl = urlBase.trim();
    if (!cleanUrl.startsWith('http')) {
      // Probar primero https, luego http
      final httpsUrl = 'https://$cleanUrl';
      if (await _testConnection(httpsUrl)) return httpsUrl;
      final httpUrl = 'http://$cleanUrl';
      if (await _testConnection(httpUrl)) return httpUrl;
      return null;
    } else {
      Uri? uri;
      try {
        uri = Uri.parse(cleanUrl);
      } catch (e) {
        if (kDebugMode) debugPrint('[Server Discovery] ✗ URL inválida: $e');
        return null;
      }
      if (uri.host.isEmpty) {
        if (kDebugMode)
          debugPrint('[Server Discovery] ✗ URL sin host: $cleanUrl');
        return null;
      }
      String testUrl = uri.origin;
      if (await _testConnection(testUrl)) return testUrl;
      return null;
    }
  }

  /// Prueba la conexión a un servidor
  static Future<bool> _testConnection(String url) async {
    try {
      if (kDebugMode) debugPrint('[Server Discovery] Intentando: $url');
      final response = await http
          .get(Uri.parse('$url$_testEndpoint'))
          .timeout(_timeout);
      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (success && kDebugMode)
        debugPrint('[Server Discovery] ✓ Conexión exitosa: $url');
      return success;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Server Discovery] ✗ Error en $url: $e\n$st');
      return false;
    }
  }
}
