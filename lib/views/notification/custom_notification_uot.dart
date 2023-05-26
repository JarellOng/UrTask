import 'package:flutter/material.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

class CustomNotificationUotView extends StatefulWidget {
  final int uot;
  final int? amount;
  final Color? color;

  const CustomNotificationUotView({
    super.key,
    required this.uot,
    this.amount,
    this.color,
  });

  @override
  State<CustomNotificationUotView> createState() =>
      _CustomNotificationUotViewState();
}

class _CustomNotificationUotViewState extends State<CustomNotificationUotView> {
  late String uotName;
  late int amount;

  @override
  void initState() {
    if (widget.uot == 0) {
      uotName = "minute";
    } else if (widget.uot == 1) {
      uotName = "hour";
    } else if (widget.uot == 2) {
      uotName = "day";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          _printUotName(),
          style: TextStyle(
            fontSize: 25,
            color: widget.color ?? HexColor.fromHex("#cdc4c4"),
          ),
        ),
      ),
    );
  }

  String _printUotName() {
    return (widget.amount != null && widget.amount! <= 1)
        ? uotName
        : "${uotName}s";
  }
}
