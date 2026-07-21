import 'package:flutter/material.dart';
import 'package:soonmodoro/features/timer/view/components/count_card.dart';

class StateRow extends StatelessWidget {
  final int sessionCount;
  final Duration focusTime;

  const StateRow({
    super.key,
    required this.sessionCount,
    required this.focusTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: CountCard(value: '$sessionCount', label: '완료 세션'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CountCard(value: '${focusTime.inMinutes}', label: '완료 시간(분)'),
        ),
      ],
    );
  }
}
