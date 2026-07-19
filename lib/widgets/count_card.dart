import 'package:flutter/material.dart';

class CountCard extends StatelessWidget {
  final int count;
  final String text;

  const CountCard({super.key, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0x0Dffffff),
        border: Border.all(color: Color(0x1fffffff), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: Color(0xff8e5cd9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: Color(0xff8a8594),
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
