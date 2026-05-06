import '../../auth/domain/auth_session.dart';
import '../../shared/models/finance_models.dart';

enum ManagedUserStatus {
  active('ACTIVE', 'Active'),
  inactive('INACTIVE', 'Inactive');

  const ManagedUserStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory ManagedUserStatus.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'INACTIVE' => ManagedUserStatus.inactive,
      _ => ManagedUserStatus.active,
    };
  }

  MemberStatus get memberStatus {
    return this == ManagedUserStatus.active
        ? MemberStatus.active
        : MemberStatus.inactive;
  }
}

class ManagedUserFilter {
  const ManagedUserFilter({this.status, this.role, this.search});

  final ManagedUserStatus? status;
  final UserRole? role;
  final String? search;

  Map<String, String> toQueryParams() {
    final String? query = search?.trim();
    return <String, String>{
      if (status != null) 'status': status!.apiValue,
      if (role != null && role != UserRole.unknown) 'role': role!.apiValue,
      if (query != null && query.isNotEmpty) 'search': query,
    };
  }
}

class ManagedUser {
  const ManagedUser({
    required this.userId,
    required this.fullName,
    required this.contactNo,
    required this.email,
    required this.joinDate,
    required this.role,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String fullName;
  final String contactNo;
  final String email;
  final String joinDate;
  final UserRole role;
  final ManagedUserStatus status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Member toMember() {
    return Member(
      id: userId,
      name: fullName.isEmpty ? 'Unnamed Member' : fullName,
      initials: initials,
      capital: 0,
      status: status.memberStatus,
      pending: 0,
    );
  }

  factory ManagedUser.fromJson(Map<String, dynamic> json) {
    return ManagedUser(
      userId: '${json['user_id'] ?? json['id'] ?? json['_id'] ?? ''}',
      fullName: '${json['full_name'] ?? json['name'] ?? ''}',
      contactNo:
          '${json['contact_no'] ?? json['phone'] ?? json['phone_number'] ?? ''}',
      email: '${json['email'] ?? ''}',
      joinDate: '${json['join_date'] ?? ''}',
      role: UserRole.fromApi(json['role'] as String?),
      status: ManagedUserStatus.fromApi(json['status'] as String?),
      notes: '${json['notes'] ?? ''}',
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }
}
