import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soonmodoro/widgets/count_card.dart';
import 'package:soonmodoro/widgets/corner_border_painter.dart';
import 'package:soonmodoro/widgets/header.dart';
import 'package:soonmodoro/models/timer_mode.dart';
import 'package:soonmodoro/widgets/selection_button.dart';

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
      _controllers[_currentControllerIndex].stop();
      _timer.cancel();

      setState(() {
        _timerIsActive = false;
      });
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
      _controllers[_currentControllerIndex].reset();
      _timerIsActive = false;
    }

    setState(() {
      HomeScreen.timerMode = mode;
      _currentControllerIndex = mode.index;
      _time = HomeScreen.timerMode.time;
    });
  }

  String format(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff141218),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Header(),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '집중 사이클 $_currentSessionCount/4',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xff8a8594),
                          letterSpacing: 2,
                        ),
                      ),
                      Row(
                        children: [
                          ...List<Container>.generate(
                            _currentSessionCount % 5,
                            (int index) {
                              return Container(
                                margin: EdgeInsets.only(left: 5),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Color(0xff8e5cd9),
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                          ...List<Container>.generate(
                            4 - (_currentSessionCount % 5),
                            (int index) {
                              return Container(
                                margin: EdgeInsets.only(left: 5),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.25 * _currentSessionCount),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: Color(0xff2A2630),
                        color: Color(0xff8e5cd9),
                        borderRadius: BorderRadius.circular(10),
                      );
                    },
                  ),
                ],
              ),

              Expanded(
                child: Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    CustomPaint(
                      size: Size(250, 250),
                      painter: CornerBorderPainter(
                        cornerLength: 20,
                        strokeWidth: 3,
                        color: Color(0xff2a2630),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controllers[_currentControllerIndex],
                      builder: (context, child) {
                        return SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value:
                                1.0 -
                                _controllers[_currentControllerIndex]
                                    .value, // 시간이 갈수록 0으로 감소
                            strokeWidth: 15,
                            strokeCap: StrokeCap.round,
                            color: Color(0xff8e5cd9),
                            backgroundColor: Color(0xff2A2630),
                          ),
                        );
                      },
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          HomeScreen.timerMode.label,
                          style: TextStyle(
                            color: Color(0xffc9c2d6),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${format(_time ~/ 60)}:${format(_time % 60)}',
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Flex(
                direction: Axis.horizontal,
                spacing: 10,
                children: TimerMode.values
                    .map(
                      (e) => Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0x0Dffffff),
                            border: Border.all(
                              color: Color(0x1fffffff),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SelectionButton(
                            timerMode: e,
                            label: e.label,
                            onTap: () => _onTap(e),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 10),

              Flex(
                direction: Axis.horizontal,
                spacing: 10,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0x0Dffffff),
                      border: Border.all(color: Color(0x1fffffff), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: _onTapReset,
                      child: Text(
                        '초기화',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0x0Dffffff),
                        border: Border.all(color: Color(0x1fffffff), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: _onTapStart,
                        child: Text(
                          _timerIsActive ? '중지' : '시작',
                          style: TextStyle(
                            color: Color(0xff8e5cd9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: CountCard(count: _totalSessionCount, text: '완료 세션'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CountCard(
                      count: _totalFocusTime ~/ 60,
                      text: '완료 시간(분)',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
