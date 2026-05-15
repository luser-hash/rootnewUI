part of 'staff_report_page.dart';

class _MoneyMetric {
  const _MoneyMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

class _TinyStat {
  const _TinyStat(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

enum _StaffReportSection {
  summary('Summary', Icons.dashboard_outlined),
  members('Members', Icons.groups_outlined),
  investments('Investments', Icons.account_balance_outlined),
  distributions('Distributions', Icons.call_split_rounded),
  approvalQueue('Approval Queue', Icons.pending_actions_outlined);

  const _StaffReportSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum _MemberStatusFilter {
  active('Active'),
  inactive('Inactive'),
  all('All');

  const _MemberStatusFilter(this.label);

  final String label;
}

enum _MemberSort { name, contact, joinDate, status, balance }

const List<String> _investmentStatusValues = <String>[
  'DRAFT',
  'OPEN',
  'CLOSED',
  'DISTRIBUTED',
  'REVERSED',
];

const List<String> _investmentTypeValues = <String>[
  'FIXED_DEPOSIT',
  'EQUITY',
  'REAL_ESTATE',
  'LENDING',
  'OTHER',
];

const List<String> _distributionStatusValues = <String>['POSTED', 'REVERSED'];

InputDecoration _fieldDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
    ),
  );
}

void _toggle(Set<String> selected, String value) {
  if (!selected.add(value)) {
    selected.remove(value);
  }
}

Color _investmentStatusColor(String status) {
  return switch (status.toUpperCase()) {
    'OPEN' => AppColors.blue,
    'CLOSED' => AppColors.amber,
    'DISTRIBUTED' => AppColors.green,
    'REVERSED' => AppColors.red,
    _ => AppColors.textMute,
  };
}

Color _channelColor(String channel) {
  return switch (channel.toUpperCase()) {
    'BKASH' => const Color(0xFFD82B7D),
    'BANK' || 'BANK_TRANSFER' => AppColors.blue,
    _ => AppColors.textMute,
  };
}
