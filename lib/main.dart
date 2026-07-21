import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soonmodoro/app/app.dart';

void main() {
  // ProviderScope는 MaterialApp 바깥에 둔다. home 안에 두면 다이얼로그·
  // 라우트처럼 Overlay에 올라가는 위젯이 스코프 밖으로 벗어난다.
  runApp(const ProviderScope(child: App()));
}
