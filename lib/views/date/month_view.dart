import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class MonthView extends StatelessWidget {
  final int month;
  final Color? color;

  const MonthView({
    super.key,
    required this.month,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          _month(count: month),
          style: TextStyle(
            fontSize: 23,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}

String _month({required int count}) {
  if (count == 0) return "JAN";
  if (count == 1) return "FEB";
  if (count == 2) return "MAR";
  if (count == 3) return "APR";
  if (count == 4) return "MAY";
  if (count == 5) return "JUN";
  if (count == 6) return "JUL";
  if (count == 7) return "AUG";
  if (count == 8) return "SEP";
  if (count == 9) return "OCT";
  if (count == 10) return "NOV";
  if (count == 11) return "DEC";
  return "";
}
