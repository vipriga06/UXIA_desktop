import '../../models/login_credentials.dart';

/// Interface for preferences service (Dependency Inversion Principle)
abstract class IPreferencesService {
  Future<LoginCredentials> loadCredentials();
  Future<void> saveCredentials(LoginCredentials credentials);
  Future<void> clearCredentials();
}
