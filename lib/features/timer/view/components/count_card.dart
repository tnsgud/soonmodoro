import 'package:flutter/material.dart';
import 'package:soonmodoro/features/timer/view/components/surface_card.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class CountCard extends StatelessWidget {
  final String value;
  final String label;

  const CountCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: mutedColor,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
