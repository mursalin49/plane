class AuthUser {
  AuthUser({
    required this.id,
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  final String id;
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String status;

  String get fullName => '$firstName $lastName'.trim();

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class AuthSessionInfo {
  AuthSessionInfo({
    required this.id,
    required this.activeStationId,
    required this.rememberMe,
    required this.expiresAt,
  });

  final String id;
  final String? activeStationId;
  final bool rememberMe;
  final DateTime? expiresAt;

  factory AuthSessionInfo.fromJson(Map<String, dynamic> json) {
    return AuthSessionInfo(
      id: json['id']?.toString() ?? '',
      activeStationId: json['activeStationId']?.toString(),
      rememberMe: json['rememberMe'] == true,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
    );
  }
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresIn,
    required this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String accessTokenExpiresIn;
  final DateTime? refreshTokenExpiresAt;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      accessTokenExpiresIn: json['accessTokenExpiresIn']?.toString() ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] == null
          ? null
          : DateTime.tryParse(json['refreshTokenExpiresAt'].toString()),
    );
  }
}

class UserSessionSnapshot {
  UserSessionSnapshot({required this.user, required this.session});

  final AuthUser? user;
  final AuthSessionInfo? session;

  factory UserSessionSnapshot.fromJson(Map<String, dynamic> json) {
    return UserSessionSnapshot(
      user: json['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      session: json['session'] is Map<String, dynamic>
          ? AuthSessionInfo.fromJson(json['session'] as Map<String, dynamic>)
          : null,
    );
  }
}
