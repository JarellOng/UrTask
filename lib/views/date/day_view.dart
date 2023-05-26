import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class DayView extends StatelessWidget {
  final int day;
  final Color? color;

  const DayView({
    super.key,
    required this.day,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          _printDay(),
          style: TextStyle(
            fontSize: 23,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }

  String _printDay() {
    return (day + 1).toString();
  }
}
