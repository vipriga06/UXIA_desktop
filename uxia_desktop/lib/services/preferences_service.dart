import 'package:shared_preferences/shared_preferences.dart';
import '../core/interfaces/i_preferences_service.dart';
import '../models/login_credentials.dart';

/// Implementation of preferences service using shared_preferences
class PreferencesService implements IPreferencesService {
  static const _urlKey = 'server_url';
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';

  @override
  Future<LoginCredentials> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return LoginCredentials(
      url: prefs.getString(_urlKey) ?? '',
      username: prefs.getString(_usernameKey) ?? '',
      password: prefs.getString(_passwordKey) ?? '',
    );
  }

  @override
  Future<void> saveCredentials(LoginCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_urlKey, credentials.url),
      prefs.setString(_usernameKey, credentials.username),
      prefs.setString(_passwordKey, credentials.password),
    ]);
  }

  @override
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_urlKey),
      prefs.remove(_usernameKey),
      prefs.remove(_passwordKey),
    ]);
  }
}
