import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class StatCard extends StatelessWidget {
  final List<String> labels = ['누석 세션', '누석 집중', '현재 연속(일)', '최고 연속(일)'];
  final List<Object> data;

  StatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        childAspectRatio: 1 / 0.5,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
      ),
      itemCount: labels.length,
      itemBuilder: (e, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: BoxBorder.all(color: surfaceBorderColor),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data[index]}',
                style: TextStyle(
                  color: index == 3 ? Colors.white : primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                labels[index],
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
