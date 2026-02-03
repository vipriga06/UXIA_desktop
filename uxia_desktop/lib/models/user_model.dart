class User {
  final String id;
  final String username;
  final String email;
  final String token;
  final DateTime loginTime;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.loginTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      loginTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'token': token,
  };
}
