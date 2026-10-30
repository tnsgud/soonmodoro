import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soonmodoro/entities/session/model/statistics_summary.dart';

class StatisticsViewModel extends AsyncNotifier<StatisticsSummary> {
  @override
  FutureOr<StatisticsSummary> build() {
    return StatisticsSummary.initial();
  }
}
