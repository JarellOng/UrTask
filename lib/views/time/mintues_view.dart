import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class MinuteView extends StatelessWidget {
  final int minutes;
  final Color? color;

  const MinuteView({
    super.key,
    required this.minutes,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          minutes < 10 ? '0$minutes' : minutes.toString(),
          style: TextStyle(
            fontSize: 25,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}
