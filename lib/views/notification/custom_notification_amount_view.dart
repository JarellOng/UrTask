import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class CustomNotificationAmountView extends StatelessWidget {
  final int amount;
  final Color? color;

  const CustomNotificationAmountView({
    super.key,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          amount.toString(),
          style: TextStyle(
            fontSize: 25,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}
