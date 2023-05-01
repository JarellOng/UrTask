import 'package:flutter/material.dart';

class MinuteView extends StatelessWidget {
  final int minutes;
  const MinuteView({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Text(
          minutes < 10 ? '0$minutes' : minutes.toString(),
          style: const TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
