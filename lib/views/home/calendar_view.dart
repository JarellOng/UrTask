import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urtask/color.dart';
import 'package:intl/intl.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/services/notifications/notifications_model.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/event/event_detail_view.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;

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
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime currentDate = DateTime.now();
  late final CategoryController _categoryController;
  late final ColorController _colorService;
  late final NotificationController _notificationService;

  @override
  void initState() {
    _calendarService = CalendarController();
    _eventService = EventController();
    _categoryController = CategoryController();
    _colorService = ColorController();
    _notificationService = NotificationController();
    setupMarker().then((value) {
      setState(() {
        eventMap = value;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    if (widget.today.text == "Today") {
      selectedDay = DateTime.now();
    } else if (widget.today.text == "Update") {
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.calendarFilter == calendar ? 330.0 : 510.0,
            ),
            child: StreamBuilder(
              stream: _eventService.getByDate(
                dateTime: selectedDay,
                excludedCategoryIds: widget.myList,
              ),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final events = snapshot.data as Iterable<Events>;
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        shrinkWrap: true,
                        itemCount: events.length,
                        separatorBuilder: (context, index) {
                          return Column();
                        },
                        itemBuilder: (context, index) {
                          final event = events.elementAt(index);
                          final startTime = event.start.toDate();
                          final endTime = event.end.toDate();
                          startDate = startTime;
                          endDate = endTime;
                          return Column(
                            children: [
                              ListTile(
                                minVerticalPadding: 0,
                                onTap: () =>
                                    _setupEventDetailDataAndPush(event: event),
                                leading: Transform.translate(
                                  offset: const Offset(-8, -6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
                                          child: Column(children: [
                                            Text(
                                              _validateStartTime(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              _validateEndTime(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black45,
                                              ),
                                            )
                                          ]),
                                        ),
                                      ),
                                      const VerticalDivider(
                                          color: Colors.black45),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  event.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Align(
                                  alignment: Alignment.topLeft,
                                  child: FutureBuilder(
                                    future: _categoryController.get(
                                        id: event.categoryId),
                                    builder: (context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.done:
                                          if (snapshot.hasData) {
                                            final category =
                                                snapshot.data as Categories;
                                            return FutureBuilder(
                                                future: _colorService.get(
                                                    id: category.colorId),
                                                builder: (context, snapshot) {
                                                  switch (snapshot
                                                      .connectionState) {
                                                    case ConnectionState.done:
                                                      if (snapshot.hasData) {
                                                        final color =
                                                            snapshot.data
                                                                as color_model
                                                                    .Colors;
                                                        return Chip(
                                                          backgroundColor:
                                                              HexColor.fromHex(
                                                                  color.hex),
                                                          label: Text(
                                                            category.name,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Column();
                                                      }
                                                    default:
                                                      return Column();
                                                  }
                                                });
                                          } else {
                                            return Column();
                                          }
                                        default:
                                          return Column();
                                      }
                                    },
                                  ),
                                ),
                                horizontalTitleGap: -2,
                                trailing: event.important
                                    ? const Icon(
                                        Icons.error_outlined,
                                        size: 32,
                                        color: Colors.red,
                                      )
                                    : null,
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.black26,
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return Column();
                    }
                  default:
                    return Column();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  void _setupEventDetailDataAndPush({required Events event}) async {
    showLoadingDialog(context: context, text: "Loading");
    late String colorHex;
    final futures = await Future.wait([
      _categoryController.get(id: event.categoryId),
      _notificationService.getByEventId(id: event.id),
    ]);
    final category = futures[0] as Categories;
    final categoryName = category.name;
    final colorId = category.colorId;
    await _colorService.get(id: colorId).then((value) {
      colorHex = value.hex;
    });
    final notifications = futures[1] as Iterable<Notifications>;
    if (mounted) {
      Navigator.of(context).pop();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailView(
            eventId: event.id,
            groupId: event.groupId,
            title: event.title,
            start: event.start,
            end: event.end,
            important: event.important,
            description: event.description,
            categoryId: event.categoryId,
            categoryName: categoryName,
            categoryHex: colorHex,
            notifications: notifications,
          ),
        ),
      );
      setupMarker().then((value) {
        setState(() {
          eventMap = value;
        });
      });
    }
  }

  String _validateStartTime() {
    int selectedStartHour = startDate.hour;
    int selectedStartMinute = startDate.minute;
    final startDateValidation = DateTimeHelper.dateToString(
      month: startDate.month,
      day: startDate.day,
      year: startDate.year,
    );
    final currentDateValidation = DateTimeHelper.dateToString(
      month: selectedDay.month,
      day: selectedDay.day,
      year: selectedDay.year,
    );

    if (startDateValidation == currentDateValidation) {
      return DateTimeHelper.timeToString(
        hour: selectedStartHour,
        minute: selectedStartMinute,
      );
    } else {
      return '00.00';
    }
  }

  String _validateEndTime() {
    int selectedEndHour = endDate.hour;
    int selectedEndMinute = endDate.minute;
    final endDateValidation = DateTimeHelper.dateToString(
      month: endDate.month,
      day: endDate.day,
      year: endDate.year,
    );
    final currentDateValidation = DateTimeHelper.dateToString(
      month: selectedDay.month,
      day: selectedDay.day,
      year: selectedDay.year,
    );
    if (endDateValidation == currentDateValidation) {
      return DateTimeHelper.timeToString(
        hour: selectedEndHour,
        minute: selectedEndMinute,
      );
    } else {
      return '23.59';
    }
  }

  void _changeSelectedDay({required DateTime selectedDay}) {
    setState(() {
      this.selectedDay = selectedDay;
      widget.selectedDate.text = selectedDay.toString().substring(0, 10);
    });
  }

  Future<Map<DateTime, List<Events>>> setupMarker() async {
    return await _eventService.getAllMarker(excludedCategoryIds: widget.myList);
  }
}
