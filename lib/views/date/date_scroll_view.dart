import 'package:flutter/material.dart';
import 'package:urtask/views/date/day_view.dart';
import 'package:urtask/views/date/month_view.dart';
import 'package:urtask/views/date/year_view.dart';

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
  int currentYear = DateTime.now().year;
  late bool isLeapYear;

  @override
  void initState() {
    isLeapYear = (currentYear % 4 == 0) &&
        (currentYear % 100 != 0 || currentYear % 400 == 0);
    if (selectedMonth == 1) {
      dayCount = isLeapYear && selectedMonth == 1 ? 29 : 28;
    } else {
      dayCount = selectedMonth.isEven ? 31 : 30;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // dayCount = selectedMonth.isEven ? 31 : 30;

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
                if (selectedMonth == 1) {
                  dayCount = isLeapYear ? 29 : 28;
                  if (selectedDay >= 29) widget.day.jumpToItem(dayCount - 1);
                } else if (selectedMonth.isEven) {
                  widget.day.jumpToItem(selectedDay);
                  dayCount = 31;
                } else {
                  if (selectedDay % 30 == 0 && selectedDay != 0) {
                    widget.day.jumpToItem(29);
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
                currentYear += selectedYear;
                isLeapYear = (currentYear % 4 == 0) &&
                    (currentYear % 100 != 0 || currentYear % 400 == 0);
                if (selectedMonth == 1) {
                  dayCount = isLeapYear ? 29 : 28;
                  widget.day.jumpToItem(27);
                }
                currentYear -= selectedYear;
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
