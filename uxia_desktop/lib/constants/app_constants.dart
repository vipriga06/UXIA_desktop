/// Constantes de la aplicación
class AppConstants {
  // API
  static const int timeoutSeconds = 10;
  static const String apiPath = '/api';
  static const String adminPath = '/admin/usuaris';
  
  // URLs de prueba (en orden de preferencia)
  static const List<String> defaultPorts = ['3000', '3307', '80', '443'];
  
  // Temas
  static const String appTitle = 'A.I.D.A administrator';
  static const int primaryColorValue = 0xFF8bc6cc;
  static const int bgColorValue = 0xFFF8FAFB;
  static const String fontFamily = 'dinnextw1g';
  
  // Responsividad
  static const double mobileBreakpoint = 600;
  
  // Timeouts UI
  static const Duration loginDialogDuration = Duration(milliseconds: 1500);
  static const Duration userCreatedDuration = Duration(seconds: 1);
  
  // Regex patterns
  static const String emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String urlPattern = r'^https?:\/\/(localhost|[\w.-]+)(:\d{1,5})?(\/.*)?$';
  
  // Mensajes
  static const String msgEmptyFields = 'Per favor, omple tots els camps';
  static const String msgInvalidEmail = 'Email invàlid. Exemple: usuari@exemple.com';
  static const String msgInvalidUrl = 'Format d\'URL invàlid. Exemple: uxia3.ieti.site';
  static const String msgServerError = 'No es pot connectar al servidor';
  static const String msgConnectionError = 'Error de connexió';
}
