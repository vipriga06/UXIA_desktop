/// Modelo de usuario
class User {
  final String id;
  final String email;
  final String nickname;
  final String? telefon;
  final String role;
  final bool validat;
  final bool tos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.telefon,
    required this.role,
    required this.validat,
    required this.tos,
    this.createdAt,
    this.updatedAt,
  });

  /// Convierte JSON a User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      telefon: json['telefon'] as String?,
      role: json['role'] as String? ?? 'user',
      validat: json['validat'] as bool? ?? false,
      tos: json['tos'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'] as String) 
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.tryParse(json['updatedAt'] as String) 
        : null,
    );
  }

  /// Convierte User a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nickname': nickname,
    'telefon': telefon,
    'role': role,
    'validat': validat,
    'tos': tos,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Copia con cambios
  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? telefon,
    String? role,
    bool? validat,
    bool? tos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      telefon: telefon ?? this.telefon,
      role: role ?? this.role,
      validat: validat ?? this.validat,
      tos: tos ?? this.tos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, nickname: $nickname)';
}

/// Modelo de respuesta de login
class LoginResponse {
  final String token;
  final String message;

  LoginResponse({
    required this.token,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['data']?['token'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

/// Modelo de usuario autenticado
class AuthUser {
  final int userId;
  final String nickname;
  final String email;
  final String? telefon;
  final String role;
  final bool validat;
  final bool tos;

  AuthUser({
    required this.userId,
    required this.nickname,
    required this.email,
    this.telefon,
    required this.role,
    required this.validat,
    required this.tos,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    int parseUserId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return AuthUser(
      userId: parseUserId(json['userId']),
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefon: json['telefon'] as String?,
      role: json['role'] as String? ?? 'user',
      validat: json['validat'] as bool? ?? false,
      tos: json['tos'] as bool? ?? false,
    );
  }
}
