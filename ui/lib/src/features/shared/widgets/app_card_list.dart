import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppCardList extends StatelessWidget {
  const AppCardList({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Column(children: children),
    );
  }
}
