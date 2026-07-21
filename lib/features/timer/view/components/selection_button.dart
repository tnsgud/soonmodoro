import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class SelectionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(color: isSelected ? primaryColor : Colors.white),
      ),
    );
  }
}
