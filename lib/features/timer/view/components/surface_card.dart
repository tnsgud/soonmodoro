import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

/// 카드·버튼에 반복되는 표면 장식.
class SurfaceCard extends StatelessWidget {
  final Widget child;

  const SurfaceCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: surfaceBorderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
