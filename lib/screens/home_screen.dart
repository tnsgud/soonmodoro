import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soonmodoro/widgets/corner_border_painter.dart';
import 'package:soonmodoro/widgets/header.dart';
import 'package:soonmodoro/models/timer_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  // ignore: prefer_final_fields
  static TimerMode timerMode = TimerMode.focus;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  late Timer _timer;

  bool _timerIsActive = false;

  final int _longBreakLimit = 4;
  int _currentControllerIndex = 0;
  int _time = TimerMode.focus.time;
  int _currentSessionCount = 0; // 0~4
  int _totalSessionCount = 0;
  int _totalFocusTime = 0;

  @override
  void initState() {
    _controllers.add(
      AnimationController(
        vsync: this,
        duration: Duration(seconds: twentyFiveMinutes),
      ),
    );
    _controllers.add(
      AnimationController(
        vsync: this,
        duration: Duration(seconds: fiveMinutes),
      ),
    );
    _controllers.add(
      AnimationController(
        vsync: this,
        duration: Duration(seconds: fifteen),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  TextButton _selectionButton({
    required TimerMode timerMode,
    required String label,
  }) {
    return TextButton(
      onPressed: () => _onTap(timerMode),
      child: Text(
        label,
        style: TextStyle(
          color: HomeScreen.timerMode == timerMode
              ? Colors.deepPurple
              : Colors.white,
        ),
      ),
    );
  }

  void _onTapStart() {
    if (_timerIsActive) {
      _timerIsActive = false;
      _timer.cancel();
      return;
    }

    _controllers[_currentControllerIndex].forward();
    setState(() {
      _timerIsActive = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), _tickTimer);
  }

  void _tickTimer(Timer timer) {
    setState(() {
      _time--;
      _totalFocusTime++;
    });

    if (_time > 0) {
      return;
    }

    _controllers[_currentControllerIndex].reset();
    switch (HomeScreen.timerMode) {
      case TimerMode.focus:
        _currentSessionCount++;
        _totalSessionCount++;
        if (_currentSessionCount % _longBreakLimit == 0) {
          HomeScreen.timerMode = TimerMode.longBreak;
          _currentControllerIndex = 2;
        } else {
          HomeScreen.timerMode = TimerMode.shortBreak;
          _currentControllerIndex = 1;
        }
        break;
      case TimerMode.longBreak:
        _currentSessionCount = 0;
        HomeScreen.timerMode = TimerMode.focus;
        _currentControllerIndex = 0;
        break;
      default:
        HomeScreen.timerMode = TimerMode.focus;
        _currentControllerIndex = 0;
        break;
    }

    setState(() {
      _timerIsActive = false;
      _time = HomeScreen.timerMode.time;
      timer.cancel();
    });
  }

  void _onTapReset() {
    _timer.cancel();
    _timerIsActive = false;
    HomeScreen.timerMode = TimerMode.focus;
    _currentSessionCount = 0;
    _controllers[_currentControllerIndex].reset();
    _currentControllerIndex = 0;

    setState(() {
      _time = HomeScreen.timerMode.time;
    });
  }

  void _onTap(TimerMode mode) {
    if (_timerIsActive) {
      _timer.cancel();
      _timerIsActive = false;
    }

    setState(() {
      HomeScreen.timerMode = mode;
      _time = HomeScreen.timerMode.time;
    });
  }

  String format(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff141218),
      body: SafeArea(
        child: Column(
          children: [
            Header(),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('집중 사이클 $_currentSessionCount/4'),
                    Row(
                      children: [
                        ...List<Container>.generate(_currentSessionCount % 5, (
                          int index,
                        ) {
                          return Container(
                            margin: EdgeInsets.only(left: 5),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                        ...List<Container>.generate(
                          4 - (_currentSessionCount % 5),
                          (int index) {
                            return Container(
                              margin: EdgeInsets.only(left: 5),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0.25 * _currentSessionCount),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    );
                  },
                ),
              ],
            ),

            Stack(
              alignment: AlignmentGeometry.center,
              children: [
                CustomPaint(
                  size: Size(200, 150),
                  painter: CornerBorderPainter(
                    cornerLength: 20,
                    strokeWidth: 3,
                    color: Colors.blue,
                  ),
                ),
                AnimatedBuilder(
                  animation: _controllers[_currentControllerIndex],
                  builder: (context, child) {
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value:
                            1.0 -
                            _controllers[_currentControllerIndex]
                                .value, // 시간이 갈수록 0으로 감소
                        strokeWidth: 8,
                        color: Colors.blue,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    );
                  },
                ),

                Column(
                  children: [
                    Text(HomeScreen.timerMode.label),
                    Text(
                      '${format(_time ~/ 60)}:${format(_time % 60)}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text('집중'),
                  ],
                ),
              ],
            ),

            Row(
              children: TimerMode.values
                  .map((e) => _selectionButton(timerMode: e, label: e.label))
                  .toList(),
            ),

            TextButton(onPressed: _onTapReset, child: Text('Reset')),

            TextButton(
              onPressed: _onTapStart,
              child: Text(_timerIsActive ? 'stop' : 'start'),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: BoxBorder.all(color: Colors.blueGrey, width: 5),
                    ),
                    child: Column(
                      children: [Text('$_totalSessionCount'), Text('완료 세션')],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: BoxBorder.all(color: Colors.blueGrey, width: 5),
                    ),
                    child: Column(
                      children: [
                        Text(format(_totalFocusTime ~/ 60)),
                        Text('집중 시간(분)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ],
            ),
          ],
        ),
      ),
    );
  }
}
