import 'package:flutter/material.dart';
import 'package:soonmodoro/features/statistics/view/components/stat_card.dart';
import 'package:soonmodoro/features/statistics/view/components/stat_chart.dart';
import 'package:soonmodoro/features/statistics/view/components/stat_header.dart';
import 'package:soonmodoro/features/statistics/view/components/stat_list.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    var cardData = [29, 12.8, 5, 5];
    var chartData = <double>[12.5, 0, 1, 0, 3, 20, 5, 3, 10];
    var listData = <StatListData>[
      StatListData(
        dateTime: DateTime.now(),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 1)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 2)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 3)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 4)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 5)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 6)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
      StatListData(
        dateTime: DateTime.now().subtract(Duration(days: 7)),
        sessionCount: 10,
        focusMinutes: 10,
      ),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatHeader(),
              SizedBox(height: 15),

              StatCard(data: cardData),

              Expanded(child: StatChart(data: chartData)),
              SizedBox(height: 15),

              Text(
                "날짜별 기록",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Flexible(child: StatList(data: listData)),
            ],
          ),
        ),
      ),
    );
  }
}
