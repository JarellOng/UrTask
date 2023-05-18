import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class YearView extends StatelessWidget {
  final int year;
  final Color? color;

  const YearView({
    super.key,
    required this.year,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          (DateTime.now().year + year).toString(),
          style: TextStyle(
            fontSize: 23,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}
