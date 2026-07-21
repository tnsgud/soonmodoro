import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

/// 알람 소리를 낼 수 없을 때 보여주는 안내.
///
/// 진동은 그대로 동작하므로 타이머 자체는 쓸 수 있다는 점을 알린다.
class AlarmNotice extends StatelessWidget {
  const AlarmNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volume_off_outlined, size: 12, color: mutedColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '알람 소리를 불러오지 못했습니다. 진동으로만 알립니다.',
              style: TextStyle(fontSize: 10, color: mutedColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
