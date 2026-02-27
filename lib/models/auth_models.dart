// lib/models/auth_models.dart

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email':    email,
        'password': password,
      };
}

// ── Response from /api/auth/login ─────────────────────────────────────────
class LoginResponse {
  final int     id;
  final String  accessToken;
  final String  refreshToken;
  final String  role;    // "USER" | "VOLUNTEER" | "ADMIN"
  final String  email;
  final String  name;
  final String? place;   // volunteer's group location — null for USER/ADMIN

  const LoginResponse({
    required this.id,
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.email,
    required this.name,
    this.place,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id:           json['id']           as int,
      accessToken:  json['accessToken']  as String,
      refreshToken: json['refreshToken'] as String,
      role:         json['role']         as String,
      email:        json['email']        as String,
      name:         json['name']         as String,
      place:        json['place']        as String?,
    );
  }
}

// ── Request body for /api/auth/signUp ─────────────────────────────────────
class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String place;
  final String role;  // "USER" | "VOLUNTEER"

  const SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.place,
    this.role = 'USER',
  });

  Map<String, dynamic> toJson() => {
        'name':     name,
        'email':    email,
        'password': password,
        'place':    place,
        'role':     role,
      };
}