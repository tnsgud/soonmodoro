import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class StatChart extends StatelessWidget {
  final List<double> data;
  const StatChart({super.key, required this.data});

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: mutedColor,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    var t = (8 - value).toInt();

    return SideTitleWidget(
      meta: meta,
      space: 5,
      child: Text(t == 0 ? '오늘' : '$t일전', style: style),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, Color(0xff4a2596)],
          ),
          width: 35,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
        ),
      ],
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: const BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, getTitlesWidget: getTitles),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: List.generate(data.length, (i) => makeGroupData(i, data[i])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 9일 집중 추이',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 30),
        Expanded(
          child: BarChart(
            randomData(),
            duration: Duration(milliseconds: 150),
            curve: Curves.linear,
          ),
        ),
      ],
    );
  }
}
