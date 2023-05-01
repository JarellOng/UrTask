import 'package:flutter/material.dart';
import 'package:urtask/views/time/hours_view.dart';
import 'package:urtask/views/time/mintues_view.dart';

class TimeScrollView extends StatefulWidget {
  final FixedExtentScrollController hour;
  final FixedExtentScrollController minute;

  const TimeScrollView({
    super.key,
    required this.hour,
    required this.minute,
  });

  @override
  State<TimeScrollView> createState() => _TimeScrollViewState();
}

class _TimeScrollViewState extends State<TimeScrollView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour
        SizedBox(
          height: 105,
          width: 100,
          child: ListWheelScrollView.useDelegate(
            controller: widget.hour,
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                25,
                (index) => HourView(hours: index),
              ),
            ),
          ),
        ),

        // Seperator
        const Text(
          ":",
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Minutes
        SizedBox(
          height: 105,
          width: 100,
          child: ListWheelScrollView.useDelegate(
            controller: widget.minute,
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                60,
                (index) => MinuteView(minutes: index),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
