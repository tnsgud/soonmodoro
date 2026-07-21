import 'package:flutter/material.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';
import 'package:soonmodoro/features/timer/view/components/selection_button.dart';
import 'package:soonmodoro/features/timer/view/components/surface_card.dart';

class ModeSelector extends StatelessWidget {
  final TimerMode selected;
  final ValueChanged<TimerMode> onSelect;

  const ModeSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      spacing: 10,
      children: TimerMode.values
          .map(
            (mode) => Expanded(
              child: SurfaceCard(
                child: SelectionButton(
                  label: mode.label,
                  isSelected: mode == selected,
                  onTap: () => onSelect(mode),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
