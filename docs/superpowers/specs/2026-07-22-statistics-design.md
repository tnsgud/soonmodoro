# 통계 기능 설계

작성일: 2026-07-22
선행: [2026-07-21-fsd-mvvm-design.md](2026-07-21-fsd-mvvm-design.md)

## 배경

FSD+MVVM 전환(PR #2, `main` 병합 완료) 위에 통계 기능을 올린다.

현재 세션은 `TimerState.sessions`로 **메모리에만** 존재해 앱을 끄면 사라진다. 통계를 하려면 세션을 영구 저장하는 것이 이 기능의 절반이다.

이 문서는 구현자가 코드를 짤 수 있을 만큼 상세한 스펙을 목표로 한다. 구현은 별도로 진행한다.

## 목표

메인 화면과 별개로 통계 화면을 두고, 완료된 집중 세션에서 네 가지를 보여준다.

1. **날짜별 기록** — "오늘 8세션 3시간", "어제 5세션"
2. **기간 합계·추이** — 이번 주/이번 달 총 집중 시간·세션 수, 주별·월별 추이
3. **연속 기록(streak)** — 며칠 연속 집중했는지, 최고 기록
4. **누적 총량** — 지금까지 총 세션·총 시간

그리고 메인 화면 상단 카드를 "오늘" 기준으로 바꿔, 앱을 꺼도 오늘 기록이 유지되게 한다.

## 비목표

- 중단한 집중 세션·휴식 세션 기록 (완료된 집중 세션만)
- 세션 편집·삭제 UI
- 목표 설정, 알림, 리마인더
- 데이터 내보내기/가져오기, 기기 간 동기화
- 기상 시각 기준 날짜 경계 (로컬 자정 고정, 아래 "결정 사항" 참고)

## 결정 사항 (브레인스토밍 확정)

| 항목 | 결정 | 근거 |
|---|---|---|
| 핵심 지표 | 날짜별·기간 추이·streak·누적 넷 다 | 사용자가 모두 원함 |
| 저장 | sqflite, 세션당 한 행 | 날짜 범위 조회·집계를 SQL로. 기록이 수만 개여도 버팀 |
| 기록 범위 | 완료된 집중 세션만 | 현재 동작 그대로. ViewModel 변경 최소 |
| 메인 카드 | "오늘" 집계로 전환 | 앱을 꺼도 유지, 자정 리셋, 통계 화면과 일관 |
| 날짜 경계 | 로컬 자정 | 표준. 필요 시 후속으로 설정화 |

### 이전 결정과의 관계

FSD 스펙에서 `SessionRepository` 인터페이스를 **뺐다** — "구현체가 영원히 하나"라는 이유였다. 이번에는 되살린다. **프로덕션은 sqflite, 테스트는 인메모리 대역**으로 구현체가 둘이 되므로 인터페이스가 값을 한다. 그때 적어둔 "필요해질 때 생기는 자리"가 지금이다.

## 의존성 추가

`pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.4.3
  path: ^1.9.0          # 이미 flutter 경유로 있으나 명시

dev_dependencies:
  sqflite_common_ffi: ^2.4.2   # 데스크톱/CI에서 flutter test로 실제 DB 검증
```

`sqflite`는 iOS/Android에서만 동작하고 `flutter test`(DartVM)에서는 채널이 없다. `sqflite_common_ffi`로 테스트에서 in-memory SQLite를 띄운다.

> 확인 필요: 위 버전은 2026-07-22 기준 pub.dev 최신이다. 구현 시 `flutter pub get`으로 해석되는 실제 버전을 확인할 것.

## 데이터 모델

### 저장 스키마

테이블 `sessions`:

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | INTEGER PRIMARY KEY AUTOINCREMENT | |
| `mode` | TEXT NOT NULL | `TimerMode.name` (현재는 항상 `focus`) |
| `started_at` | INTEGER NOT NULL | epoch milliseconds, 로컬 |
| `ended_at` | INTEGER NOT NULL | epoch milliseconds, 로컬 |

인덱스: `CREATE INDEX idx_sessions_started_at ON sessions(started_at)` — 날짜 범위 조회·정렬용.

`mode` 컬럼은 지금은 항상 `focus`지만, 나중에 휴식 세션을 기록하게 될 때 스키마 변경 없이 확장된다. 현재 저장 시 `focus`로 고정하고 조회 시 `WHERE mode = 'focus'`로 거른다.

`duration`은 저장하지 않는다. `ended_at - started_at`으로 파생된다 — [Session](../../../lib/entities/session/model/session.dart)의 현재 규칙과 같다.

### 도메인 모델 (기존 유지 + 확장)

`Session`([entities/session/model/session.dart](../../../lib/entities/session/model/session.dart))에 `id`를 추가한다. 저장 전에는 null, 저장 후 DB가 채운다.

```dart
class Session {
  final int? id;              // 신규: 저장 전 null
  final TimerMode mode;
  final DateTime startedAt;
  final DateTime endedAt;
  Duration get duration => endedAt.difference(startedAt);
  bool get isFocus => mode == TimerMode.focus;

  Map<String, Object?> toRow();          // 신규
  factory Session.fromRow(Map<String, Object?> row);  // 신규
}
```

`toRow`/`fromRow`는 DB 표현과의 변환만 담당한다. `id`가 null이면 `toRow`는 `id` 키를 넣지 않는다(AUTOINCREMENT에 맡김).

### 집계 결과 모델

통계 화면이 소비할 값 객체들. 전부 `entities/session/model/`에 둔다(도메인 개념이므로).

```dart
/// 하루치 집계.
class DailyStat {
  final DateTime date;       // 자정 정규화
  final int sessionCount;
  final Duration focusTime;
}

/// 통계 화면 전체 상태.
class StatisticsSummary {
  final int totalSessions;       // 누적
  final Duration totalFocusTime; // 누적
  final int currentStreak;       // 현재 연속 일수
  final int longestStreak;       // 최고 연속 일수
  final List<DailyStat> recentDays;   // 최근 N일 (추이 그래프용)
  final DailyStat today;              // 메인 카드용 편의
}
```

## 아키텍처

### 레이어 배치

```
entities/session/
├── model/
│   ├── session.dart              (기존, id + 직렬화 추가)
│   ├── daily_stat.dart           (신규)
│   └── statistics_summary.dart   (신규)
└── api/                          (신규 세그먼트)
    ├── session_repository.dart   인터페이스
    ├── session_dao.dart          sqflite 구현
    └── app_database.dart         Database 열기/스키마/마이그레이션

features/statistics/
├── model/
│   ├── statistics_view_model.dart   AsyncNotifier
│   └── statistics_providers.dart    repository·today provider
└── view/
    ├── statistics_screen.dart
    └── components/
        ├── summary_cards.dart        누적·streak 카드
        ├── trend_chart.dart          최근 N일 막대그래프
        └── daily_list.dart           날짜별 리스트

features/timer/
├── view_model/timer_view_model.dart  (_complete에서 저장소로도 기록)
└── ...
```

### 의존성 방향

`features/statistics → entities/session → shared`. 기존 규칙(`app → features → entities → shared`)을 그대로 따른다. `features/timer`와 `features/statistics`는 **서로 참조하지 않고** 둘 다 `entities/session/api`를 공유한다.

### SessionRepository 인터페이스

```dart
abstract interface class SessionRepository {
  Future<Session> add(Session session);        // id 채워 반환
  Future<StatisticsSummary> loadSummary({int recentDays});
  Future<DailyStat> loadDay(DateTime date);     // 메인 카드 "오늘"용
}
```

집계는 화면이 아니라 저장소 뒤에서 SQL로 수행한다. ViewModel은 인터페이스만 본다.

- **프로덕션**: `SqfliteSessionRepository` (`session_dao.dart`)
- **테스트**: `InMemorySessionRepository` — 리스트 하나로 같은 계약을 Dart로 구현. sqflite 없이 ViewModel·화면 테스트

두 구현이 **같은 계약**을 만족해야 하므로, 계약 테스트를 공유한다(아래 "테스트").

### SQL 집계

| 지표 | 쿼리 개요 |
|---|---|
| 날짜별 | `SELECT date(started_at/1000,'unixepoch','localtime') d, COUNT(*), SUM(ended_at-started_at) FROM sessions WHERE mode='focus' GROUP BY d ORDER BY d DESC` |
| 오늘 | 위에서 `WHERE d = date('now','localtime')` |
| 누적 | `SELECT COUNT(*), SUM(ended_at-started_at) FROM sessions WHERE mode='focus'` |
| streak | 날짜별 결과(날짜 오름차순)를 Dart에서 순회하며 연속 구간 계산 |

> 주의: SQLite의 `date(...,'localtime')`은 서버 타임존이 아니라 기기 로컬을 쓴다. `started_at`이 millis이므로 `/1000`으로 초 단위 변환 후 `unixepoch`. 이 변환식은 구현 시 실제 값으로 검증할 것(경계 케이스: 자정 직전 세션).

streak를 SQL 윈도우 함수로도 짤 수 있으나, 날짜별 집계가 이미 있으니 Dart에서 계산하는 편이 읽기 쉽고 테스트가 쉽다.

**streak 계산 규칙** (구현·테스트가 이 정의를 따른다):

- 세션이 하나라도 있는 날을 "활동일"로 본다.
- **현재 streak**: 오늘부터 하루씩 거슬러 올라가며 활동일이 연속된 일수. 단, 시작점은 오늘 **또는** 어제여야 한다 — 오늘 아직 안 했어도 어제까지 이어졌으면 streak는 유효(오늘 하면 이어짐). 그저께가 마지막이면 현재 streak는 0.
- **최고 streak**: 전체 기록에서 가장 긴 연속 활동일 구간.
- 활동일이 하나도 없으면 둘 다 0.

## 타이머 연동

`TimerViewModel._complete()`([timer_view_model.dart:130](../../../lib/features/timer/view_model/timer_view_model.dart))에서 집중 세션이 완료될 때 저장소에도 기록한다.

**제약: `_complete()`는 동기다.** 구독 해제 → 세션 기록 → 모드 전환이 동기라 재진입이 불가능한 것이 현재 설계의 핵심이다(PR #1의 재진입 버그 방지). DB 저장은 비동기이므로, **알람과 똑같이 fire-and-forget**으로 띄운다. 동기 흐름을 깨지 않는다.

```dart
// _complete() 안, 기존 alarm.ring()과 같은 위치
if (finishedMode == TimerMode.focus) {
  _alarm.ring();
  _repository.add(completedSession);   // await 하지 않음
}
```

저장 실패가 타이머 진행을 막아서는 안 된다. `add`는 내부에서 예외를 잡아 로그만 남긴다(오디오 서비스와 같은 방침).

메인 화면의 "완료 세션 / 완료 시간(분)" 카드는 `TimerState.sessions`(메모리) 대신 `todayStatsProvider`(DB의 오늘 집계)를 읽도록 바꾼다. 세션이 하나 저장되면 provider를 무효화해 카드가 갱신된다.

> 열린 질문: 세션 저장 후 `todayStatsProvider` 갱신을 어떻게 트리거할지(리스너 vs `ref.invalidate` vs 저장소가 스트림 노출). 구현 시 가장 단순한 방법으로 시작하고, 필요하면 스트림으로 승격.

`TimerState.sessions` 필드는 통계가 DB로 옮겨가면 **메모리 목록이 불필요해진다.** 다만 `completedFocusCount`/`totalFocusTime`이 여기 의존하므로, 메인 카드를 DB로 옮긴 뒤 이 필드와 파생 getter를 제거할지 결정한다(별도 정리 항목).

## 화면 구성

메인 화면 헤더나 별도 진입점에서 통계 화면으로 이동(네비게이션 방식은 구현 시 결정 — 현재 라우팅이 없으므로 `Navigator.push` 또는 탭 도입).

통계 화면(위→아래):

1. **요약 카드** — 누적 총 세션·총 시간, 현재 streak·최고 streak
2. **추이 그래프** — 최근 N일(기본 7일) 막대그래프. 막대 높이 = 그날 집중 시간
3. **날짜별 리스트** — 날짜 내림차순, 각 행에 세션 수·시간. 오늘/어제는 라벨로 표기

빈 상태(기록 없음)를 반드시 다룬다 — "아직 완료한 집중 세션이 없습니다".

색상·카드 스타일은 `shared/ui/app_colors`와 기존 `SurfaceCard`를 재사용한다. `CountCard`를 통계에서도 쓰게 되면 그때 최상위 `components/`로 승격한다(FSD 승격 규칙).

## 에러·엣지 케이스

- **DB 열기 실패**: 통계 화면은 에러 상태를 표시(`AsyncNotifier`의 error). 타이머는 저장 없이 계속 동작
- **세션 저장 실패**: 로그만, 타이머 진행 유지
- **자정을 걸친 세션**: `started_at` 기준 날짜에 귀속(단순·일관)
- **기기 시계 변경**: 벽시계 기반이므로 과거로 되돌리면 같은 날짜에 겹칠 수 있음. 혼자 쓰는 앱이라 허용
- **빈 데이터**: streak 0, 추이 빈 막대, 리스트 빈 상태 문구
- **매우 짧은 세션**(디버그 5초): 그대로 기록. 통계는 시간 합만 보므로 무해

## 테스트

**계약 테스트 공유** — `SqfliteSessionRepository`와 `InMemorySessionRepository`가 같은 테스트 스위트를 통과해야 한다. `sqflite_common_ffi`로 in-memory DB를 띄워 실제 SQL을 검증한다.

- 세션 추가 후 `id`가 채워지는가
- 누적 카운트·시간 합이 맞는가
- 날짜별 그룹핑이 로컬 자정 경계를 지키는가 (자정 직전/직후 세션)
- streak: 연속/끊김/오늘까지/어제까지/빈 데이터
- 기간 필터(이번 주/이번 달)

**ViewModel 테스트** — `InMemorySessionRepository`를 provider override로 주입. clock으로 "오늘"을 고정.

**화면 테스트** — 빈 상태, 데이터 있는 상태, 에러 상태.

**타이머 연동** — 집중 완료 시 `repository.add`가 정확히 한 번 호출되는지(가짜 저장소), 저장 실패가 상태 전환을 막지 않는지.

## 검증

- `flutter analyze` 무경고
- `flutter test` 통과 (계약 테스트 포함)
- 실기기: 세션 완료 → 통계에 반영 → 앱 재시작 후에도 유지 → 자정 지나면 "오늘" 리셋

## 후속 (이 스펙 범위 밖)

- `TimerState.sessions` 메모리 목록 제거
- 기상 시각 기준 날짜 경계 설정
- 목표 설정·달성 알림
- 데이터 내보내기
