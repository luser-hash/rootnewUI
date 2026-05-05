import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    required this.color,
    required this.size,
    required this.radius,
    this.active,
  });

  final String initials;
  final Color color;
  final double size;
  final double radius;
  final bool? active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            initials,
            style: TextStyle(
              fontSize: size >= 60 ? 24 : 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        if (active != null)
          Positioned(
            bottom: -3,
            right: -3,
            child: Container(
              width: size >= 46 ? 13 : 12,
              height: size >= 46 ? 13 : 12,
              decoration: BoxDecoration(
                color: active! ? AppColors.green : AppColors.textMute,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
