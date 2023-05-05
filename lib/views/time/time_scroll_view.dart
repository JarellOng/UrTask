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
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    selectedHour = widget.hour.initialItem;
    selectedMinute = widget.minute.initialItem;
    super.initState();
  }

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
            onSelectedItemChanged: (value) => setState(() {
              selectedHour = value;
            }),
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                25,
                (index) {
                  if (selectedHour == index) {
                    return HourView(
                      hours: index,
                      color: Colors.black,
                    );
                  }
                  return HourView(hours: index);
                },
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
            onSelectedItemChanged: (value) => setState(() {
              selectedMinute = value;
            }),
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                60,
                (index) {
                  if (selectedMinute == index) {
                    return MinuteView(
                      minutes: index,
                      color: Colors.black,
                    );
                  }
                  return MinuteView(minutes: index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
