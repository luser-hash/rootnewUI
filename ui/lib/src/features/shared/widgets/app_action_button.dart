import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
