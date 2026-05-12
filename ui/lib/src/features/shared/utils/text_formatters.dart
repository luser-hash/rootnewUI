String valueOrDash(String? value) {
  final String text = value?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}

String prettyEnumLabel(String value) {
  final String normalized = value.trim().replaceAll('_', ' ').toLowerCase();
  if (normalized.isEmpty) {
    return '-';
  }

  return normalized
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
