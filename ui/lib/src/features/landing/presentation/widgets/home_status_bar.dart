part of '../landing_page.dart';

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: dark ? 0 : 0);
  }
}
