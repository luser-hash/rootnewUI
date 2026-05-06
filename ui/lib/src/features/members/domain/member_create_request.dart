class MemberCreateRequest {
  const MemberCreateRequest({
    required this.fullName,
    required this.contactNo,
    required this.email,
    required this.joinDate,
    required this.notes,
    required this.password,
  });

  final String fullName;
  final String contactNo;
  final String email;
  final DateTime joinDate;
  final String notes;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'full_name': fullName,
      'contact_no': contactNo,
      'email': email,
      'join_date': _formatDate(joinDate),
      'role': 'MEMBER',
      'notes': notes,
      'password': password,
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
