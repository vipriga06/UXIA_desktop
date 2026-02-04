/// Model for login credentials
class LoginCredentials {
  final String url;
  final String username;
  final String password;

  const LoginCredentials({
    this.url = '',
    this.username = '',
    this.password = '',
  });

  LoginCredentials copyWith({String? url, String? username, String? password}) {
    return LoginCredentials(
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  bool get isEmpty => url.isEmpty && username.isEmpty && password.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get isValid =>
      url.isNotEmpty && username.isNotEmpty && password.isNotEmpty && isValidUrl;

  /// Valida que la URL tenga el formato correcto: http://IP:puerto
  /// Ejemplo: http://127.0.0.2:3000
  bool get isValidUrl {
    if (url.isEmpty) return false;
    
    final urlPattern = RegExp(
      r'^https?:\/\/([\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}|localhost):[\d]{1,5}$',
      caseSensitive: false,
    );
    
    return urlPattern.hasMatch(url.trim());
  }

  /// Retorna un mensaje de error si la URL no es válida
  String? get urlError {
    if (url.isEmpty) return null;
    if (!isValidUrl) {
      return 'Format d\'URL invàlid. Exemple: http://127.0.0.2:3000';
    }
    return null;
  }
}
