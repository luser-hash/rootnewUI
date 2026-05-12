import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

const List<Color> avatarColors = <Color>[
  AppColors.primary,
  Color(0xFF5B6AD1),
  AppColors.accent,
  AppColors.green,
  AppColors.red,
  Color(0xFF7B52AB),
];

Color avatarColor(int index) => avatarColors[index % avatarColors.length];

String formatMoneySigned(num value) {
  final String sign = value < 0 ? '-' : '';
  return '$sign${formatMoneyUnsigned(value)}';
}

String formatMoneyUnsigned(num value) {
  final double absValue = value.abs().toDouble();
  final String fixed = absValue.toStringAsFixed(2);
  final List<String> parts = fixed.split('.');
  final String grouped = _groupBangladeshi(parts.first);

  return '৳$grouped.${parts.last}';
}

String formatMoneyTextSigned(String? value) {
  return formatMoneySigned(num.tryParse(value ?? '') ?? 0);
}

String formatMoneyCompactSigned(num value) {
  final String sign = value < 0 ? '-' : '';
  final double absValue = value.abs().toDouble();
  if (absValue >= 1000) {
    return '$sign৳${(absValue / 1000).toStringAsFixed(1)}K';
  }
  return '$sign৳${absValue.toStringAsFixed(0)}';
}

String fmt(num value) {
  return formatMoneyUnsigned(value);
}

String fmtSh(num value) {
  return formatMoneyCompactSigned(value.abs());
}

String _groupBangladeshi(String whole) {
  if (whole.length <= 3) {
    return whole;
  }

  final String lastThree = whole.substring(whole.length - 3);
  String head = whole.substring(0, whole.length - 3);
  final List<String> groups = <String>[];

  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) {
    groups.insert(0, head);
  }

  return '${groups.join(',')},$lastThree';
}
