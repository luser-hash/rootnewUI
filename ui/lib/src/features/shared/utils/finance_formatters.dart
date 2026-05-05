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

String fmt(num value) {
  final double absValue = value.abs().toDouble();
  final String fixed = absValue.toStringAsFixed(2);
  final List<String> parts = fixed.split('.');
  final String whole = parts.first;
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < whole.length; i++) {
    final int fromRight = whole.length - i;
    buffer.write(whole[i]);
    if (fromRight > 1 && fromRight % 3 == 1) {
      buffer.write(',');
    }
  }

  return '৳$buffer.${parts.last}';
}

String fmtSh(num value) {
  final double absValue = value.abs().toDouble();
  if (absValue >= 1000) {
    return '৳${(absValue / 1000).toStringAsFixed(1)}K';
  }
  return '৳${absValue.toStringAsFixed(0)}';
}
