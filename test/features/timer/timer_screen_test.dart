import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_durations.dart';
import 'package:soonmodoro/features/alarm/model/alarm_provider.dart';
import 'package:soonmodoro/features/timer/view/timer_screen.dart';
import 'package:soonmodoro/features/timer/view_model/timer_view_model.dart';

import '../../support/fake_services.dart';

Widget buildSubject() {
  return ProviderScope(
    overrides: [
      timerDurationsProvider.overrideWithValue(
        const TimerDurations(
          focus: Duration(minutes: 25),
          shortBreak: Duration(minutes: 5),
          longBreak: Duration(minutes: 15),
        ),
      ),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      hapticServiceProvider.overrideWithValue(FakeHapticService()),
    ],
    child: const MaterialApp(home: TimerScreen()),
  );
}

void main() {
  testWidgets('초기 화면에 남은 시간과 컨트롤이 보인다', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('집중'), findsWidgets);
    expect(find.text('시작'), findsOneWidget);
    expect(find.text('초기화'), findsOneWidget);
    expect(find.text('집중 사이클 0/4'), findsOneWidget);
  });

  testWidgets('시작을 누르면 버튼이 중지로 바뀐다', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('시작'));
    await tester.pump();

    expect(find.text('중지'), findsOneWidget);
    expect(find.text('시작'), findsNothing);
  });

  testWidgets('모드를 바꾸면 표시 시간이 따라 바뀐다', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('긴 휴식'));
    await tester.pump();

    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets('세로 화면에서 오버플로가 없다', (tester) async {
    await tester.pumpWidget(buildSubject());
    expect(tester.takeException(), isNull);
  });
}
