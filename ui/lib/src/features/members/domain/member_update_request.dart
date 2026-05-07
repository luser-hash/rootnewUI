import '../../auth/domain/auth_session.dart';
import 'member_management_models.dart';

class MemberUpdateRequest {
  const MemberUpdateRequest({
    required this.fullName,
    required this.contactNo,
    required this.email,
    required this.notes,
    required this.role,
    required this.status,
    required this.joinDate,
  });

  final String fullName;
  final String contactNo;
  final String email;
  final String notes;
  final UserRole role;
  final ManagedUserStatus status;
  final DateTime joinDate;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'full_name': fullName,
      'contact_no': contactNo,
      'email': email,
      'notes': notes,
      'role': role.apiValue,
      'status': status.apiValue,
      'join_date': _formatDate(joinDate),
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
