import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class StatListData {
  final DateTime dateTime;
  final int sessionCount;
  final int focusMinutes;

  const StatListData({
    required this.dateTime,
    required this.sessionCount,
    required this.focusMinutes,
  });
}

class StatList extends StatelessWidget {
  final List<StatListData> data;
  final DateFormat _format = DateFormat.MMMEd('ko-kr');

  StatList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _format.format(data[index].dateTime),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${data[index].sessionCount}세션',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
            Text(
              '${data[index].focusMinutes}분',
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => Divider(color: surfaceBorderColor),
    );
  }
}
