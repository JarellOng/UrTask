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
          (day + 1).toString(),
          style: TextStyle(
            fontSize: 20,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}
