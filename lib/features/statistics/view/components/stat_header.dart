import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class StatHeader extends StatelessWidget {
  const StatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STATISTICS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: mutedStrongColor,
                letterSpacing: 3,
              ),
            ),
            Text(
              '기록 통계',
              style: TextStyle(
                color: primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
