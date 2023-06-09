import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urtask/color.dart';
import 'package:intl/intl.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/views/home/event_view.dart';

class CalendarView extends StatefulWidget {
  final CalendarFormat calendarFilter;
  final TextEditingController today;
  final TextEditingController selectedDate;
  final List<String> myList;
  const CalendarView({
    super.key,
    required this.calendarFilter,
    required this.today,
    required this.selectedDate,
    required this.myList,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime current = DateTime.now();
  DateTime selectedDay = DateTime.now();
  CalendarFormat calendar = CalendarFormat.month;
  late final CalendarController _calendarService;
  late final EventController _eventService;
  Map<DateTime, List<Events>> eventMap = {};

  @override
  void initState() {
    _calendarService = CalendarController();
    _eventService = EventController();
    setupMarker().then((value) {
      setState(() {
        eventMap = value;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    if (oldWidget.today.text == "Today") {
      selectedDay = DateTime.now();
      setupMarker().then((value) {
        setState(() {
          eventMap = value;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: TableCalendar(
              focusedDay: _calendarService.showToday(today: widget.today) ??
                  selectedDay,
              firstDay: DateTime.utc(2023, 01, 01),
              lastDay: DateTime.utc(2123, 12, 31),
              rowHeight: 45,
              calendarFormat: widget.calendarFilter,
              headerVisible: false,
              onDaySelected: (selectedDay, focusedDay) =>
                  _changeSelectedDay(selectedDay: selectedDay),
              onPageChanged: (focusedDay) =>
                  _changeSelectedDay(selectedDay: focusedDay),
              eventLoader: (day) {
                return eventMap[
                            DateTime.parse(day.toString().substring(0, 23))] !=
                        null
                    ? [1]
                    : [];
              },
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 56, 56),
                  shape: BoxShape.circle,
                ),
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
              child: Text(
                DateFormat('yMMMMd').format(selectedDay),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (widget.calendarFilter == calendar) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 330.0,
              ),
              child: EventView(selectedDay: selectedDay, myList: widget.myList),
            )
          ] else ...[
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 510.0,
              ),
              child: EventView(selectedDay: selectedDay, myList: widget.myList),
            )
          ]
        ],
      ),
    );
  }

  void _changeSelectedDay({required DateTime selectedDay}) {
    setState(() {
      this.selectedDay = selectedDay;
      widget.selectedDate.text = selectedDay.toString().substring(0, 10);
      setupMarker().then((value) {
        setState(() {
          eventMap = value;
        });
      });
    });
  }

  Future<Map<DateTime, List<Events>>> setupMarker() async {
    return await _eventService.getAllMarker(excludedCategoryIds: widget.myList);
  }
}
