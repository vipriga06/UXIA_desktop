import 'package:uxia_desktop/services/storage_service.dart';

class LoginCredentials {
  final String urlServidor;
  final String nomUsuari;
  final String contrasenya;

  const LoginCredentials({
    this.urlServidor = '',
    this.nomUsuari = '',
    this.contrasenya = '',
  });

  bool get isValid =>
      urlServidor.isNotEmpty && nomUsuari.isNotEmpty && contrasenya.isNotEmpty;
}

class CredentialsService {
  static const _urlKey = 'url';
  static const _usuariKey = 'usuari';
  static const _contrasenyaKey = 'contrasenya';

  final IStorageService _storage;

  CredentialsService(this._storage);

  Future<LoginCredentials> loadCredentials() async {
    final url = await _storage.getString(_urlKey) ?? '';
    final user = await _storage.getString(_usuariKey) ?? '';
    final password = await _storage.getString(_contrasenyaKey) ?? '';

    return LoginCredentials(
      urlServidor: url,
      nomUsuari: user,
      contrasenya: password,
    );
  }

  Future<void> saveCredentials(LoginCredentials credentials) async {
    await Future.wait([
      _storage.setString(_urlKey, credentials.urlServidor),
      _storage.setString(_usuariKey, credentials.nomUsuari),
      _storage.setString(_contrasenyaKey, credentials.contrasenya),
    ]);
  }

  Future<void> clearCredentials() async {
    await Future.wait([
      _storage.remove(_urlKey),
      _storage.remove(_usuariKey),
      _storage.remove(_contrasenyaKey),
    ]);
  }
}
