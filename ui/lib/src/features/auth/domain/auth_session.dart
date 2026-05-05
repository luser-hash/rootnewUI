class AuthSession {
  const AuthSession({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;

  AuthSession copyWith({AuthUser? user, AuthTokens? tokens}) {
    return AuthSession(user: user ?? this.user, tokens: tokens ?? this.tokens);
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _asMap(json['data']) ?? json;
    return AuthSession(
      user: AuthUser.fromJson(_asMap(data['user']) ?? <String, dynamic>{}),
      tokens: AuthTokens.fromJson(data),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user': user.toJson(), ...tokens.toJson()};
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.email,
    this.status,
    this.joinDate,
  });

  final String id;
  final String phone;
  final String name;
  final UserRole role;
  final String? email;
  final String? status;
  final String? joinDate;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: '${json['user_id'] ?? json['id'] ?? json['_id'] ?? ''}',
      phone:
          '${json['contact_no'] ?? json['phone'] ?? json['phone_number'] ?? ''}',
      name: '${json['name'] ?? json['full_name'] ?? 'Member'}',
      role: UserRole.fromApi(json['role'] as String?),
      email: json['email'] as String?,
      status: json['status'] as String?,
      joinDate: json['join_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'phone': phone,
      'name': name,
      'role': role.apiValue,
      if (email != null) 'email': email,
      if (status != null) 'status': status,
      if (joinDate != null) 'join_date': joinDate,
    };
  }
}

enum UserRole {
  member,
  admin,
  superAdmin,
  unknown;

  factory UserRole.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'MEMBER' => UserRole.member,
      'ADMIN' => UserRole.admin,
      'SUPER_ADMIN' || 'SUPERADMIN' => UserRole.superAdmin,
      _ => UserRole.unknown,
    };
  }

  String get apiValue {
    return switch (this) {
      UserRole.member => 'MEMBER',
      UserRole.admin => 'ADMIN',
      UserRole.superAdmin => 'SUPER_ADMIN',
      UserRole.unknown => 'UNKNOWN',
    };
  }

  String get label {
    return switch (this) {
      UserRole.member => 'Member',
      UserRole.admin => 'Admin',
      UserRole.superAdmin => 'Super Admin',
      UserRole.unknown => 'Unknown',
    };
  }
}

extension UserRolePermissions on UserRole {
  bool get canViewHome => this != UserRole.unknown;
  bool get canSubmitFunds => this != UserRole.unknown;
  bool get canViewOwnProfile => this != UserRole.unknown;
  bool get canViewApprovals => _isAdminOrAbove;
  bool get canViewMembers => _isAdminOrAbove;
  bool get canViewOwnInvestments => this != UserRole.unknown;
  bool get canViewAllInvestments => _isAdminOrAbove;
  bool get canViewOwnLedger => this != UserRole.unknown;
  bool get canViewAllLedger => _isAdminOrAbove;
  bool get canDistribute => _isAdminOrAbove;
  bool get canViewOwnReports => this != UserRole.unknown;
  bool get canViewAllReports => _isAdminOrAbove;
  bool get canManagePermissions => this == UserRole.superAdmin;

  bool get _isAdminOrAbove {
    return this == UserRole.admin || this == UserRole.superAdmin;
  }
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  bool get isExpired {
    final DateTime? expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return !expiry.isAfter(DateTime.now());
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final String accessToken =
        '${json['access'] ?? json['access_token'] ?? json['accessToken'] ?? json['token'] ?? ''}';
    final Object? expiresIn =
        json['expires_at'] ??
        json['expiresAt'] ??
        json['expires_in'] ??
        json['expiresIn'] ??
        json['expires'];

    return AuthTokens(
      accessToken: accessToken,
      refreshToken:
          json['refresh'] as String? ??
          json['refresh_token'] as String? ??
          json['refreshToken'] as String?,
      expiresAt: _parseExpiresAt(expiresIn),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  static DateTime? _parseExpiresAt(Object? value) {
    if (value is int) {
      return DateTime.now().add(Duration(seconds: value));
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}
