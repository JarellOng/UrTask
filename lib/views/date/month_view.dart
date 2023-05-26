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
          _printMonth(index: month),
          style: TextStyle(
            fontSize: 23,
            color: color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }
}

String _printMonth({required int index}) {
  if (index == 0) return "JAN";
  if (index == 1) return "FEB";
  if (index == 2) return "MAR";
  if (index == 3) return "APR";
  if (index == 4) return "MAY";
  if (index == 5) return "JUN";
  if (index == 6) return "JUL";
  if (index == 7) return "AUG";
  if (index == 8) return "SEP";
  if (index == 9) return "OCT";
  if (index == 10) return "NOV";
  if (index == 11) return "DEC";
  return "";
}
