import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_durations.dart';
import 'package:soonmodoro/features/alarm/model/alarm_provider.dart';
import 'package:soonmodoro/features/timer/view/timer_screen.dart';
import 'package:soonmodoro/features/timer/view_model/timer_view_model.dart';

import '../../support/fake_services.dart';

Widget buildSubject({
  TimerDurations durations = const TimerDurations(
    focus: Duration(minutes: 25),
    shortBreak: Duration(minutes: 5),
    longBreak: Duration(minutes: 15),
  ),
}) {
  return ProviderScope(
    overrides: [
      timerDurationsProvider.overrideWithValue(durations),
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

  group('링과 숫자 동기화', () {
    const shortDurations = TimerDurations(
      focus: Duration(seconds: 10),
      shortBreak: Duration(seconds: 6),
      longBreak: Duration(seconds: 8),
    );

    double? ringValue(WidgetTester tester) => tester
        .widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        )
        .value;

    testWidgets('매 초 링이 표시된 남은 시간과 일치한다', (tester) async {
      await tester.pumpWidget(buildSubject(durations: shortDurations));
      await tester.tap(find.text('시작'));
      await tester.pump();

      // 10초 타이머이므로 남은 초 / 10 이 링 값이어야 한다.
      for (var elapsed = 1; elapsed <= 9; elapsed++) {
        await tester.pump(const Duration(seconds: 1));

        final left = 10 - elapsed;
        expect(
          find.text('00:0$left'),
          findsOneWidget,
          reason: '$elapsed초 시점의 표시',
        );
        expect(
          ringValue(tester),
          closeTo(left / 10, 0.001),
          reason: '$elapsed초 시점의 링',
        );
      }
    });

    testWidgets('완료 시 링이 역방향으로 돌지 않고 즉시 채워진다', (tester) async {
      await tester.pumpWidget(buildSubject(durations: shortDurations));
      await tester.tap(find.text('시작'));
      await tester.pump();

      await tester.pump(const Duration(seconds: 10));

      // 짧은 휴식(6초)으로 넘어가며 링이 곧바로 가득 찬다.
      expect(find.text('00:06'), findsOneWidget);
      expect(ringValue(tester), closeTo(1.0, 0.001));
    });

    testWidgets('초기화하면 링이 즉시 가득 찬다', (tester) async {
      await tester.pumpWidget(buildSubject(durations: shortDurations));
      await tester.tap(find.text('시작'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));

      await tester.tap(find.text('초기화'));
      await tester.pump();

      expect(find.text('00:10'), findsOneWidget);
      expect(ringValue(tester), closeTo(1.0, 0.001));
    });
  });
}
