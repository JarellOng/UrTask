import 'package:flutter/material.dart';
import 'package:urtask/views/date/day_view.dart';
import 'package:urtask/views/date/month_view.dart';
import 'package:urtask/views/date/year_view.dart';
import 'package:urtask/views/time/hours_view.dart';
import 'package:urtask/views/time/mintues_view.dart';

class DateScrollView extends StatefulWidget {
  final FixedExtentScrollController day;
  final FixedExtentScrollController month;
  final FixedExtentScrollController year;

  const DateScrollView({
    super.key,
    required this.day,
    required this.month,
    required this.year,
  });

  @override
  State<DateScrollView> createState() => _DateScrollViewState();
}

class _DateScrollViewState extends State<DateScrollView> {
  int selectedMonth = DateTime.now().month - 1;
  int selectedDay = DateTime.now().day - 1;
  int dayCount = 31;
  int selectedYear = 0;

  @override
  Widget build(BuildContext context) {
    dayCount = selectedMonth.isEven ? 31 : 30;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Month
        SizedBox(
          height: 90,
          width: 90,
          child: ListWheelScrollView.useDelegate(
            controller: widget.month,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedMonth = value;
                if (selectedMonth.isEven) {
                  widget.day.jumpToItem(selectedDay);
                  dayCount = 31;
                } else {
                  if (selectedDay % 30 == 0) {
                    widget.day.jumpToItem(0);
                  } else {
                    widget.day.jumpToItem(selectedDay);
                  }
                  dayCount = 30;
                }
              });
            },
            itemExtent: 30,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                12,
                (index) {
                  if (selectedMonth == index) {
                    return MonthView(
                      month: index,
                      color: Colors.black,
                    );
                  }
                  return MonthView(month: index);
                },
              ),
            ),
          ),
        ),

        // Day
        SizedBox(
          height: 90,
          width: 90,
          child: ListWheelScrollView.useDelegate(
            controller: widget.day,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedDay = value;
              });
            },
            itemExtent: 30,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                dayCount,
                (index) {
                  if (selectedDay == index) {
                    return DayView(
                      day: index,
                      color: Colors.black,
                    );
                  }
                  return DayView(day: index);
                },
              ),
            ),
          ),
        ),

        // Year
        SizedBox(
          height: 90,
          width: 90,
          child: ListWheelScrollView.useDelegate(
            controller: widget.year,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedYear = value;
              });
            },
            itemExtent: 30,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildListDelegate(
              children: List<Widget>.generate(
                11,
                (index) {
                  if (selectedYear == index) {
                    return YearView(
                      year: index,
                      color: Colors.black,
                    );
                  }
                  return YearView(year: index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
