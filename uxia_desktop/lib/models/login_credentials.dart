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
      url.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}
