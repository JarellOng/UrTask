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
  late int selectedMonth;
  late int selectedDay;
  late int selectedYear;
  late int dayCount;
  late bool isLeapYear;
  int currentYear = DateTime.now().year;

  @override
  void initState() {
    selectedMonth = widget.month.initialItem;
    selectedDay = widget.day.initialItem;
    selectedYear = widget.year.initialItem;
    currentYear += selectedYear;
    isLeapYear = (currentYear % 4 == 0) &&
        (currentYear % 100 != 0 || currentYear % 400 == 0);
    if (selectedMonth == 1) {
      dayCount = isLeapYear ? 29 : 28;
    } else {
      dayCount = selectedMonth.isEven && selectedMonth <= 6 ||
              selectedMonth == 7 ||
              selectedMonth == 9 ||
              selectedMonth == 11
          ? 31
          : 30;
    }
    currentYear -= selectedYear;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Month
        SizedBox(
          height: 105,
          width: 90,
          child: ListWheelScrollView.useDelegate(
            controller: widget.month,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedMonth = value;
                if (selectedMonth == 1) {
                  dayCount = isLeapYear ? 29 : 28;
                  if (selectedDay >= 29) widget.day.jumpToItem(dayCount - 1);
                  if (selectedDay == 28 && dayCount == 29) {
                    widget.day.jumpToItem(28);
                  }
                } else if (selectedMonth.isEven && selectedMonth <= 6 ||
                    selectedMonth == 7 ||
                    selectedMonth == 9 ||
                    selectedMonth == 11) {
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
            itemExtent: 35,
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
          height: 105,
          width: 90,
          child: ListWheelScrollView.useDelegate(
            controller: widget.day,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedDay = value;
              });
            },
            itemExtent: 35,
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
          height: 105,
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
                  if (selectedDay == 28) {
                    widget.day.jumpToItem(dayCount - 1);
                  } else {
                    widget.day.jumpToItem(selectedDay);
                  }
                }
                currentYear -= selectedYear;
              });
            },
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildListDelegate(
              children: List<Widget>.generate(
                111,
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
