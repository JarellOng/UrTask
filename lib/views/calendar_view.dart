import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urtask/color.dart';
import 'package:intl/intl.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/views/event_view.dart';

class CalendarView extends StatefulWidget {
  final CalendarFormat calendarFilter;
  final TextEditingController today;
  final TextEditingController selectedDate;
  const CalendarView({
    super.key,
    required this.calendarFilter,
    required this.today,
    required this.selectedDate,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime selectedDay = DateTime.now();
  DateTime pilihanDay = DateTime.now();
  late final CalendarController _calendarService;

  @override
  void initState() {
    _calendarService = CalendarController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    if (oldWidget.today.text == "Today") {
      selectedDay = DateTime.now();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 20.0,
          ),
          child: TableCalendar(
            focusedDay:
                _calendarService.showToday(today: widget.today) ?? selectedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2025, 10, 16),
            rowHeight: 45,
            calendarFormat: widget.calendarFilter,
            headerVisible: false,
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
              });
              widget.selectedDate.text =
                  selectedDay.toString().substring(0, 10);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                selectedDay = focusedDay;
              });
              widget.today.text = DateFormat('yMMMM').format(selectedDay);
              widget.selectedDate.text =
                  selectedDay.toString().substring(0, 10);
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },
            calendarStyle: const CalendarStyle(
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
        const Divider(
          height: 2,
          thickness: 2,
          color: Colors.black26,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 16.0, left: 16.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(DateFormat('yMMMMd').format(selectedDay),
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w600))),
        ),
        EventView(selectedDay: selectedDay)
      ],
    );
  }
}
