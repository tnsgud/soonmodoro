import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';
import 'package:soonmodoro/features/timer/view/components/timer_dial.dart';

Widget buildSubject({
  required double space,
  Duration remaining = const Duration(minutes: 25),
  Duration total = const Duration(minutes: 25),
  TimerMode mode = TimerMode.focus,
  bool isRunning = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: space,
          height: space,
          child: TimerDial(
            mode: mode,
            remaining: remaining,
            total: total,
            isRunning: isRunning,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('남은 시간과 모드 라벨을 보여준다', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        space: 400,
        remaining: const Duration(minutes: 4, seconds: 5),
        mode: TimerMode.shortBreak,
      ),
    );

    expect(find.text('04:05'), findsOneWidget);
    expect(find.text('짧은 휴식'), findsOneWidget);
  });

  testWidgets('진행률은 남은 시간 비율을 따른다', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        space: 400,
        remaining: const Duration(minutes: 5),
        total: const Duration(minutes: 20),
      ),
    );
    await tester.pumpAndSettle();

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, closeTo(0.25, 0.001));
  });

  testWidgets('공간이 넉넉하면 원래 크기를 유지한다', (tester) async {
    await tester.pumpWidget(buildSubject(space: 400));

    // 다이얼 250 → 링 200
    expect(tester.getSize(find.byType(CircularProgressIndicator)).width, 200);
  });

  testWidgets('공간이 좁으면 그에 맞춰 줄어든다', (tester) async {
    await tester.pumpWidget(buildSubject(space: 150));

    // 다이얼 150 → 링 120
    expect(tester.getSize(find.byType(CircularProgressIndicator)).width, 120);
    expect(tester.takeException(), isNull);
  });

  testWidgets('total이 0이어도 터지지 않는다', (tester) async {
    await tester.pumpWidget(
      buildSubject(space: 400, remaining: Duration.zero, total: Duration.zero),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('00:00'), findsOneWidget);
  });
}
