import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class HourView extends StatelessWidget {
  final int hours;
  final Color? color;

  const HourView({
    super.key,
    required this.hours,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          hours < 10 ? '0$hours' : hours.toString(),
          style: TextStyle(
            fontSize: 23,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}
