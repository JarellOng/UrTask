import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urtask/color.dart';
import 'package:intl/intl.dart';
import 'package:urtask/views/event_view.dart';

class CalendarView extends StatefulWidget {
  final CalendarFormat calendarFilter;
  final TextEditingController today;
  const CalendarView({
    super.key,
    required this.calendarFilter,
    required this.today,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime selectedDay = DateTime.now();
  // DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 20.0,
          ),
          child: TableCalendar(
            focusedDay: _showToday() ?? selectedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2025, 10, 16),
            rowHeight: 45,
            calendarFormat: widget.calendarFilter,
            headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMM(locale).format(date),
                formatButtonVisible: false,
                leftChevronVisible: false,
                rightChevronVisible: false),
            //headerVisible: false,
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                // focusedDay = focusDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                selectedDay = focusedDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },
            calendarStyle: CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.red),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tertiary,
              ),
            ),
          ),
        ),
        Divider(
          height: 2,
          thickness: 2,
          color: Colors.black26,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 16.0, left: 16.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(DateFormat('yMMMMd').format(selectedDay),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
        ),
        EventView(selectedDay: selectedDay)
      ],
    );
  }

  DateTime? _showToday() {
    if (widget.today.text == "Today" && selectedDay != DateTime.now()) {
      setState(() {
        selectedDay = DateTime.now();
      });
      widget.today.text = "";
      return selectedDay;
    }
    return null;
  }
}
