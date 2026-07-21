# FSD + MVVM 구조 전환 설계

작성일: 2026-07-21
브랜치: `feature/change-to-fsd+mvvm`

## 배경

현재 앱은 652줄이고 그중 `lib/screens/home_screen.dart`가 465줄(71%)이다. 이 한 파일에 UI 트리, 타이머 로직, 오디오, 진동, 세션 카운트가 모두 들어 있다. PR #1 리뷰에서 나온 버그 대부분이 "로직과 UI가 한 덩어리라 상태 변화를 추적하기 어렵다"는 데서 비롯됐다.

앞으로 기록·설정·통계 화면을 추가할 계획이며, FSD와 MVVM을 학습하는 것도 목적이다.

## 목표

- `home_screen.dart`를 레이어별로 분해한다
- 타이머 로직을 위젯에서 분리해 테스트 가능하게 만든다
- 기록·설정·통계가 올라탈 경계를 미리 잡는다

## 비목표

이번 작업에 포함하지 않는다.

- 가로모드 대응 (구조 전환 후 별도 진행)
- 세션 데이터 영속화 (기록 화면 스펙에서)
- 백그라운드 알림 (`flutter_local_notifications`)
- 알람 무한 반복 UX 변경

기존 동작은 아래 "동작 변경" 항목을 제외하고 그대로 옮긴다.

## 레이어 명명

Flutter 관용어를 쓴다. FSD 자료와 대조할 때 참고할 대응표:

| 이 프로젝트 | FSD 원문 | 의미 |
|---|---|---|
| `app/` | app | 진입점, DI, 테마 |
| `screens/` | pages | 라우팅 단위 화면 |
| `components/` | widgets | 재사용 조합 블록 (현재 없음) |
| `features/` | features | 사용자 행위 + ViewModel |
| `entities/` | entities | 도메인 모델 |
| `shared/` | shared | 범용 유틸·UI킷 |

세그먼트(`ui/`, `model/`, `api/`, `lib/`)는 FSD 원문 그대로 쓴다.

의존성은 `app → screens → components → features → entities → shared` 방향으로만 흐르고, 같은 레이어끼리는 참조하지 않는다.

### 승격 규칙

**소비자가 둘 이상 생겼을 때 위 레이어로 올린다.** 현재 화면이 `timer` 하나뿐이므로 모든 컴포넌트는 `screens/timer/ui/components/`에 둔다. 최상위 `components/` 레이어는 만들지 않는다. 기록 화면이 `CountCard`를 재사용하는 시점에 승격한다.

"가로모드에서도 쓴다"는 승격 사유가 아니다. 세로든 가로든 같은 `timer` 화면이므로 소비자는 하나다.

## 디렉터리 구조

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── theme/app_theme.dart
├── screens/
│   └── timer/ui/
│       ├── timer_screen.dart
│       └── components/
│           ├── timer_header.dart
│           ├── timer_dial.dart
│           ├── corner_border_painter.dart
│           ├── cycle_progress.dart
│           ├── mode_selector.dart
│           ├── selection_button.dart
│           ├── timer_controls.dart
│           ├── stats_row.dart
│           ├── count_card.dart
│           └── surface_card.dart
├── features/
│   ├── timer/model/
│   │   ├── timer_state.dart
│   │   └── timer_view_model.dart
│   └── alarm/model/alarm_controller.dart
├── entities/
│   ├── timer_mode/model/timer_mode.dart
│   └── session/model/session.dart
└── shared/
    ├── ui/app_colors.dart
    └── lib/
        ├── audio_service.dart
        ├── haptic_service.dart
        └── duration_format.dart
```

## 파일별 내용

### shared/

**`shared/ui/app_colors.dart`** — 현재 5개 파일에 흩어진 색상 상수 8종.

**`shared/lib/duration_format.dart`** — `String formatMmSs(Duration)`.

**`shared/lib/audio_service.dart`**

```dart
class AudioService {
  Future<void> init();           // audio_session configure + setAsset
  Future<void> playFromStart();  // seek(0) + play
  Future<void> stop();
  void dispose();
  bool get isReady;              // init 실패 시 false
}
```

`just_audio`와 `audio_session`을 아는 유일한 파일. `init()`은 두 단계를 각각 try/catch로 감싸고, 실패 시 `isReady`를 false로 둔다.

**`shared/lib/haptic_service.dart`**

```dart
class HapticService {
  Future<void> tap();
  Future<void> alarm({Duration duration});
  Future<void> cancel();
}
```

`hasVibrator()` 결과를 최초 1회만 조회해 캐시한다. 현재는 알람마다 플랫폼 채널을 왕복한다.

### entities/

**`entities/timer_mode/model/timer_mode.dart`**

```dart
enum TimerMode { focus('집중'), shortBreak('짧은 휴식'), longBreak('긴 휴식') }

class TimerDurations {
  factory TimerDurations.real();   // 25 / 5 / 15분
  factory TimerDurations.debug();  // 10 / 3 / 5초
  Duration of(TimerMode mode);
}
```

`int` 초 대신 `Duration`을 쓴다. `kDebugMode` 삼항 연산자가 enum에서 빠지고, 어느 쪽을 쓸지는 `app/`에서 provider를 만들 때 한 번 정한다. 테스트는 원하는 값을 직접 주입한다.

**`entities/session/model/session.dart`**

```dart
class Session {
  final TimerMode mode;
  final DateTime startedAt;
  final DateTime endedAt;
  Duration get duration;
  bool get isFocus;
}
```

저장소도 인터페이스도 만들지 않는다. 기기 하나에서 혼자 쓰는 앱이라 구현체가 영원히 하나이고, Riverpod의 provider override로 테스트 대역을 넣을 수 있어 인터페이스의 명분이 없다. 영속화가 필요해지면 `entities/session/api/`에 추가한다.

### features/

**`features/timer/model/timer_state.dart`**

```dart
class TimerState {
  final TimerMode mode;
  final Duration remaining;
  final bool isRunning;
  final int cycleCount;          // 0~3
  final List<Session> sessions;

  int get completedFocusCount;
  Duration get totalFocusTime;
  TimerState copyWith({...});
}
```

통계는 전부 세션 목록에서 파생한다. 현재는 `_currentSessionCount` / `_totalSessionCount` / `_totalFocusTime`을 각각 증가시키다 서로 어긋나는데, 하나에서 계산하면 어긋날 여지가 없다.

**`features/timer/model/timer_view_model.dart`**

```dart
class TimerViewModel extends Notifier<TimerState> {
  @override TimerState build();
  void start();
  void pause();
  void reset();
  void selectMode(TimerMode mode);
}
```

시간 계산은 **종료 시각 기준**으로 한다.

```dart
// start()
_endsAt = clock.now().add(state.remaining);

// 매 틱
final left = _endsAt.difference(clock.now());
if (left <= Duration.zero) _complete();
```

`Timer.periodic`은 N초에 정확히 N번 발화를 보장하지 않고 밀린 만큼 몰아 쏘지도 않는다. 틱을 세면 타이머가 실제보다 길어진다. 틱은 화면 갱신 신호로만 쓰고 시간의 근거는 벽시계에 둔다.

완료 처리 순서를 못박는다: **구독 해제 → `Session` 추가 → 모드 전환 → 알람 호출(fire-and-forget).** 앞의 셋이 동기라 재진입이 구조적으로 불가능하다. PR #1에서 나온 `timer.cancel()` 타이밍 버그가 재발할 수 없는 형태다.

구독 정리는 `ref.onDispose`에서 한다.

**`features/alarm/model/alarm_controller.dart`**

```dart
class AlarmController {
  AlarmController(this._audio, this._haptic);
  Future<void> ring();
  Future<void> stop();   // 오디오 정지 + 진동 취소
  void dispose();
}
```

정지 경로가 하나다. 현재는 시작·초기화·모드변경 세 곳에 같은 코드가 복붙돼 있고, `dispose()`에서 진동만 빠뜨렸던 것도 이 중복 때문이었다.

### screens/

**`screens/timer/ui/timer_screen.dart`** — `ConsumerWidget`. `ref`를 아는 유일한 위젯이다. 상태를 읽어 컴포넌트에 props로 내려준다.

**`screens/timer/ui/components/`** — 전부 props와 콜백만 받는 순수 위젯.

| 파일 | 시그니처 |
|---|---|
| `timer_header.dart` | 인자 없음 |
| `timer_dial.dart` | `{TimerMode mode, Duration remaining, double progress}` |
| `corner_border_painter.dart` | 현행 유지 |
| `cycle_progress.dart` | `{int cycleCount}` |
| `mode_selector.dart` | `{TimerMode selected, ValueChanged<TimerMode> onSelect}` |
| `selection_button.dart` | `{String label, bool isSelected, VoidCallback onTap}` |
| `timer_controls.dart` | `{bool isRunning, VoidCallback onToggle, VoidCallback onReset}` |
| `stats_row.dart` | `{int sessionCount, Duration focusTime}` |
| `count_card.dart` | `{String value, String label}` |
| `surface_card.dart` | `{Widget child}` — 반복되는 Container 데코 |

`timer_dial.dart`는 `LayoutBuilder`로 `min(maxWidth, maxHeight)`를 받아 스스로 크기를 정한다. 현재의 250×250 / 200×200 하드코딩이 사라져 가로모드 작업 때 이 파일을 손댈 필요가 없다.

`selection_button.dart`가 `isSelected`를 받으면서 `HomeScreen.timerMode` static 참조가 끊긴다.

### app/

- **`main.dart`** — `runApp(ProviderScope(child: App()))`
- **`app/app.dart`** — `MaterialApp`. `TimerDurations` provider를 `kDebugMode`에 따라 override
- **`app/theme/app_theme.dart`** — `ThemeData`. `app_colors`를 소비

## 테스트 전략

`clock` + `fake_async`로 시계와 타이머를 함께 제어한다. `FakeAsync.run()`이 `withClock()`으로 시계를 갈아끼우면서 Zone의 `createTimer`/`createPeriodicTimer`도 가로채므로, 별도의 Ticker 추상화가 필요 없다.

프로덕션 코드는 `DateTime.now()` 대신 `clock.now()`만 쓰면 된다.

```dart
test('집중 세션이 끝나면 짧은 휴식으로 전환된다', () {
  fakeAsync((async) {
    final container = ProviderContainer(overrides: [...]);
    container.read(timerViewModelProvider.notifier).start();
    async.elapse(const Duration(minutes: 25));
    expect(container.read(timerViewModelProvider).mode, TimerMode.shortBreak);
  });
});
```

`pubspec.yaml`에 `clock`을 direct dependency로 승격하고 `fake_async`를 `dev_dependencies`에 명시한다. 둘 다 이미 `flutter_test` 경유로 받아져 있다.

`test/widget_test.dart`는 Flutter 카운터 템플릿이 그대로 남아 현재 `flutter test`가 실패한다. 이번 작업에서 삭제하고 실제 테스트로 교체한다.

## 동작 변경

**"완료 시간(분)"이 완료된 세션만 집계한다.** 현재는 매초 `_totalFocusTime++`이라 진행 중인 세션도 실시간 반영된다. 세션 목록에서 파생하면 완료 시점에만 증가한다. 라벨이 "완료 시간"이므로 이쪽이 맞다. 실시간 표시가 필요해지면 진행 중 세션의 경과분을 더하는 getter를 추가한다.

**휴식 시간이 집중 시간에 합산되지 않는다.** 이미 PR #1에서 고쳤으나, 파생값으로 바뀌면서 구조적으로 보장된다.

## 검증

- `flutter analyze` 무경고
- `flutter test` 통과 (현재 실패 상태에서 벗어남)
- 실기기에서 기존 동작 확인: 타이머 시작·정지·초기화, 모드 전환, 사이클 4회 후 긴 휴식, 알람 소리·진동, 알람 중 버튼 조작 시 정지
