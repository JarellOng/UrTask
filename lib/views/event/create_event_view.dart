import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/enums/repeat_duration_enum.dart';
import 'package:urtask/enums/repeat_type_enum.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/utilities/dialogs/categories_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/date/date_scroll_view.dart';
import 'package:urtask/views/event/notification_event_view.dart';
import 'package:urtask/views/event/repeat_event_view.dart';
import 'package:urtask/views/time/time_scroll_view.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  late final EventController _eventService;
  late final CategoryController _categoryService;
  late final ColorController _colorService;

  late final TextEditingController _eventTitle;
  late final TextEditingController _eventDescription;

  // All Day
  bool allDay = false;

  // Start
  late FixedExtentScrollController _eventStartDay;
  late FixedExtentScrollController _eventStartMonth;
  late FixedExtentScrollController _eventStartYear;
  late FixedExtentScrollController _eventStartHour;
  late FixedExtentScrollController _eventStartMinute;
  late DateTime selectedStartDateTime;
  int selectedStartDay = DateTime.now().day - 1;
  int selectedStartMonth = DateTime.now().month - 1;
  int selectedStartYear = DateTime.now().year;
  int selectedStartHour = DateTime.now().hour + 1;
  int selectedStartMinute = 0;
  bool startDateScrollToggle = false;
  bool startTimeScrollToggle = false;

  // End
  late FixedExtentScrollController _eventEndDay;
  late FixedExtentScrollController _eventEndMonth;
  late FixedExtentScrollController _eventEndYear;
  late FixedExtentScrollController _eventEndHour;
  late FixedExtentScrollController _eventEndMinute;
  late DateTime selectedEndDateTime;
  int selectedEndDay = DateTime.now().day - 1;
  int selectedEndMonth = DateTime.now().month - 1;
  int selectedEndYear = DateTime.now().year;
  int selectedEndHour = DateTime.now().hour + 2;
  int selectedEndMinute = 0;
  bool endDateScrollToggle = false;
  bool endTimeScrollToggle = false;

  // Important
  bool important = false;

  // Category
  String categoryId = "category3";
  String categoryName = "Meeting";
  String categoryHex = "#039be5";

  // Repeat
  RepeatType selectedRepeatType = RepeatType.noRepeat;
  RepeatDuration selectedRepeatDuration = RepeatDuration.specificNumber;

  // Notification
  bool notificationFlag = true;
  Map<NotificationTime, NotificationType> selectedNotifications = {
    NotificationTime.tenMinsBefore: NotificationType.alert
  };

  @override
  void initState() {
    _eventService = EventController();
    _eventTitle = TextEditingController();
    _eventDescription = TextEditingController();
    _categoryService = CategoryController();
    _colorService = ColorController();
    selectedStartDateTime = DateTime(
      selectedStartYear,
      selectedStartMonth + 1,
      selectedStartDay + 1,
      selectedStartHour,
      selectedStartMinute,
    );
    selectedEndDateTime = DateTime(
      selectedEndYear,
      selectedEndMonth + 1,
      selectedEndDay + 1,
      selectedEndHour,
      selectedEndMinute,
    );
    super.initState();
  }

  @override
  void dispose() {
    _eventTitle.dispose();
    _eventDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Create Event",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TITLE
            TextField(
              controller: _eventTitle,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: "Title",
              ),
            ),

            // ALL DAY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("All Day"),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: allDay,
                    onChanged: (value) {
                      setState(() {
                        allDay = value;
                        if (startTimeScrollToggle == true) {
                          _startTimeScrollOff();
                        }
                        if (endTimeScrollToggle == true) {
                          _endTimeScrollOff();
                        }
                      });
                    },
                    activeColor: primary,
                  ),
                ),
              ],
            ),

            // START
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Start"),

                // Date
                if (startDateScrollToggle == false) ...[
                  TextButton(
                    onPressed: () {
                      if (startTimeScrollToggle == true) {
                        _startTimeScrollOff();
                      }
                      if (endDateScrollToggle == true) {
                        _endDateScrollOff();
                      }
                      if (endTimeScrollToggle == true) {
                        _endTimeScrollOff();
                      }
                      _startDateScrollOn();
                    },
                    child: Text(
                      _dateToString(
                        month: selectedStartDateTime.month - 1,
                        day: selectedStartDateTime.day - 1,
                        year: selectedStartDateTime.year,
                      ),
                    ),
                  ),
                ],
                if (startDateScrollToggle == true) ...[
                  TextButton(
                    onPressed: () {
                      _startDateScrollOff();
                    },
                    child: const Text("..."),
                  ),
                ],

                // Time
                if (allDay == false) ...[
                  if (startTimeScrollToggle == false) ...[
                    TextButton(
                      onPressed: () {
                        if (startDateScrollToggle == true) {
                          _startDateScrollOff();
                        }
                        if (endDateScrollToggle == true) {
                          _endDateScrollOff();
                        }
                        if (endTimeScrollToggle == true) {
                          _endTimeScrollOff();
                        }
                        _startTimeScrollOn();
                      },
                      child: Text(
                        _timeToString(
                          hour: selectedStartDateTime.hour,
                          minute: selectedStartDateTime.minute,
                        ),
                      ),
                    ),
                  ],
                  if (startTimeScrollToggle == true) ...[
                    TextButton(
                      onPressed: () {
                        _startTimeScrollOff();
                      },
                      child: const Text("..."),
                    ),
                  ],
                ],
              ],
            ),
            if (startDateScrollToggle == true) ...[
              // Date Scroll
              DateScrollView(
                day: _eventStartDay,
                month: _eventStartMonth,
                year: _eventStartYear,
              ),
            ],
            if (startTimeScrollToggle == true) ...[
              // Time Scroll
              TimeScrollView(
                hour: _eventStartHour,
                minute: _eventStartMinute,
              ),
            ],

            // END
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("End"),

                // Date
                if (endDateScrollToggle == false) ...[
                  TextButton(
                    onPressed: () {
                      if (startDateScrollToggle == true) {
                        _startDateScrollOff();
                      }
                      if (startTimeScrollToggle == true) {
                        _startTimeScrollOff();
                      }
                      if (endTimeScrollToggle == true) {
                        _endTimeScrollOff();
                      }
                      _endDateScrollOn();
                    },
                    child: Text(
                      _dateToString(
                        month: selectedEndDateTime.month - 1,
                        day: selectedEndDateTime.day - 1,
                        year: selectedEndDateTime.year,
                      ),
                    ),
                  ),
                ],
                if (endDateScrollToggle == true) ...[
                  TextButton(
                    onPressed: () {
                      _endDateScrollOff();
                    },
                    child: const Text("..."),
                  ),
                ],

                // Time
                if (allDay == false) ...[
                  if (endTimeScrollToggle == false) ...[
                    TextButton(
                      onPressed: () {
                        if (startDateScrollToggle == true) {
                          _startDateScrollOff();
                        }
                        if (startTimeScrollToggle == true) {
                          _startTimeScrollOff();
                        }
                        if (endDateScrollToggle == true) {
                          _endDateScrollOff();
                        }
                        _endTimeScrollOn();
                      },
                      child: Text(
                        _timeToString(
                          hour: selectedEndDateTime.hour,
                          minute: selectedEndDateTime.minute,
                        ),
                      ),
                    ),
                  ],
                  if (endTimeScrollToggle == true) ...[
                    TextButton(
                      onPressed: () {
                        _endTimeScrollOff();
                      },
                      child: const Text("..."),
                    ),
                  ],
                ],
              ],
            ),
            if (endDateScrollToggle == true) ...[
              // Date Scroll
              DateScrollView(
                day: _eventEndDay,
                month: _eventEndMonth,
                year: _eventEndYear,
              ),
            ],
            if (endTimeScrollToggle == true) ...[
              // Time Scroll
              TimeScrollView(
                hour: _eventEndHour,
                minute: _eventEndMinute,
              ),
            ],

            // Important
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Important"),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: important,
                    onChanged: (value) {
                      setState(() {
                        important = value;
                      });
                    },
                    activeColor: primary,
                  ),
                ),
              ],
            ),

            // Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Category"),
                TextButton(
                  onPressed: () async {
                    final categoryDetail = await showCategoriesDialog(
                      context,
                      _categoryService,
                      _colorService,
                    );
                    if (categoryDetail.isNotEmpty) {
                      setState(() {
                        categoryId = categoryDetail[0];
                        categoryName = categoryDetail[1];
                        categoryHex = categoryDetail[2];
                      });
                    }
                  },
                  child: Chip(
                    backgroundColor: HexColor.fromHex(categoryHex),
                    label: Text(
                      categoryName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // REPEAT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Repeat"),
                TextButton(
                  onPressed: () async {
                    final repeatDetail = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RepeatEventView(
                          type: selectedRepeatType,
                          duration: selectedRepeatDuration,
                        ),
                      ),
                    );
                    setState(() {
                      selectedRepeatType = repeatDetail[0];
                      selectedRepeatDuration = repeatDetail[1];
                    });
                  },
                  child: const Text("Repeat"),
                ),
              ],
            ),

            // NOTIFICATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Notification"),
                TextButton(
                  onPressed: () async {
                    final notificationDetail = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationEventView(
                          flag: notificationFlag,
                          notifications: selectedNotifications,
                        ),
                      ),
                    );
                    setState(() {
                      notificationFlag = notificationDetail[0];
                      selectedNotifications = notificationDetail[1];
                    });
                  },
                  child: const Text("Notification"),
                ),
              ],
            ),

            // DESCRIPTION
            TextField(
              controller: _eventDescription,
              enableSuggestions: false,
              autocorrect: false,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Description",
              ),
            ),

            // SAVE BUTTON
            TextButton(
              onPressed: () async {
                // final startDay = _eventStartDay.selectedItem;
                // final startHour = _eventStartHour.selectedItem;
                // final startMinute = _eventStartMinute.selectedItem;
                // print(startDay);
                // print(startMinute);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _startDateScrollOn() {
    setState(() {
      _eventStartDay = FixedExtentScrollController(
        initialItem: selectedStartDay,
      );
      _eventStartMonth = FixedExtentScrollController(
        initialItem: selectedStartMonth,
      );
      _eventStartYear = FixedExtentScrollController(
        initialItem: selectedStartYear % DateTime.now().year,
      );
    });
    setState(() {
      startDateScrollToggle = true;
    });
  }

  void _startDateScrollOff() {
    setState(() {
      selectedStartDay = _eventStartDay.selectedItem;
      selectedStartMonth = _eventStartMonth.selectedItem % 12;
      selectedStartYear = DateTime.now().year + _eventStartYear.selectedItem;

      if (selectedStartMonth == 1) {
        if ((selectedStartYear % 4 == 0) &&
            (selectedStartYear % 100 != 0 || selectedStartYear % 400 == 0)) {
          selectedStartDay %= 29;
        } else {
          selectedStartDay %= 28;
        }
      } else if (selectedStartMonth.isEven && selectedStartMonth <= 6 ||
          selectedStartMonth == 7 ||
          selectedStartMonth == 9 ||
          selectedStartMonth == 11) {
        selectedStartDay %= 31;
      } else {
        selectedStartDay %= 30;
      }
    });
    setState(() {
      startDateScrollToggle = false;
      selectedStartDateTime = DateTime(
        selectedStartYear,
        selectedStartMonth + 1,
        selectedStartDay + 1,
        selectedStartHour,
        selectedStartMinute,
      );
      if (selectedStartDateTime.isAfter(selectedEndDateTime)) {
        selectedEndDateTime =
            selectedStartDateTime.add(const Duration(hours: 1));
        selectedEndDay = selectedEndDateTime.day - 1;
        selectedEndMonth = selectedEndDateTime.month - 1;
        selectedEndYear = selectedEndDateTime.year;
        selectedEndHour = selectedEndDateTime.hour;
        selectedEndMinute = selectedEndDateTime.minute;
      }
    });
  }

  void _startTimeScrollOn() {
    setState(() {
      _eventStartHour = FixedExtentScrollController(
        initialItem: selectedStartHour,
      );
      _eventStartMinute = FixedExtentScrollController(
        initialItem: selectedStartMinute,
      );
    });
    setState(() {
      startTimeScrollToggle = true;
    });
  }

  void _startTimeScrollOff() {
    setState(() {
      selectedStartHour = _eventStartHour.selectedItem % 24;
      selectedStartMinute = _eventStartMinute.selectedItem % 60;
    });
    setState(() {
      startTimeScrollToggle = false;
      selectedStartDateTime = DateTime(
        selectedStartYear,
        selectedStartMonth + 1,
        selectedStartDay + 1,
        selectedStartHour,
        selectedStartMinute,
      );
      if (selectedStartDateTime.isAfter(selectedEndDateTime)) {
        selectedEndDateTime =
            selectedStartDateTime.add(const Duration(hours: 1));
        selectedEndDay = selectedEndDateTime.day - 1;
        selectedEndMonth = selectedEndDateTime.month - 1;
        selectedEndYear = selectedEndDateTime.year;
        selectedEndHour = selectedEndDateTime.hour;
        selectedEndMinute = selectedEndDateTime.minute;
      }
    });
  }

  void _endDateScrollOn() {
    setState(() {
      _eventEndDay = FixedExtentScrollController(
        initialItem: selectedEndDay,
      );
      _eventEndMonth = FixedExtentScrollController(
        initialItem: selectedEndMonth,
      );
      _eventEndYear = FixedExtentScrollController(
        initialItem: selectedEndYear % DateTime.now().year,
      );
    });
    setState(() {
      endDateScrollToggle = true;
    });
  }

  void _endDateScrollOff() {
    setState(() {
      selectedEndDay = _eventEndDay.selectedItem;
      selectedEndMonth = _eventEndMonth.selectedItem % 12;
      selectedEndYear = DateTime.now().year + _eventEndYear.selectedItem;

      if (selectedEndMonth == 1) {
        if ((selectedEndYear % 4 == 0) &&
            (selectedEndYear % 100 != 0 || selectedEndYear % 400 == 0)) {
          selectedEndDay %= 29;
        } else {
          selectedEndDay %= 28;
        }
      } else if (selectedEndMonth.isEven && selectedEndMonth <= 6 ||
          selectedEndMonth == 7 ||
          selectedEndMonth == 9 ||
          selectedEndMonth == 11) {
        selectedEndDay %= 31;
      } else {
        selectedEndDay %= 30;
      }
    });
    setState(() {
      endDateScrollToggle = false;
      selectedEndDateTime = DateTime(
        selectedEndYear,
        selectedEndMonth + 1,
        selectedEndDay + 1,
        selectedEndHour,
        selectedEndMinute,
      );
      if (selectedEndDateTime.isBefore(selectedStartDateTime)) {
        selectedStartDateTime =
            selectedEndDateTime.subtract(const Duration(hours: 1));
        selectedStartDay = selectedStartDateTime.day - 1;
        selectedStartMonth = selectedStartDateTime.month - 1;
        selectedStartYear = selectedStartDateTime.year;
        selectedStartHour = selectedStartDateTime.hour;
        selectedStartMinute = selectedStartDateTime.minute;
      }
    });
  }

  void _endTimeScrollOn() {
    setState(() {
      _eventEndHour = FixedExtentScrollController(
        initialItem: selectedEndHour,
      );
      _eventEndMinute = FixedExtentScrollController(
        initialItem: selectedEndMinute,
      );
    });
    setState(() {
      endTimeScrollToggle = true;
    });
  }

  void _endTimeScrollOff() {
    setState(() {
      selectedEndHour = _eventEndHour.selectedItem % 24;
      selectedEndMinute = _eventEndMinute.selectedItem % 60;
    });
    setState(() {
      endTimeScrollToggle = false;
      selectedEndDateTime = DateTime(
        selectedEndYear,
        selectedEndMonth + 1,
        selectedEndDay + 1,
        selectedEndHour,
        selectedEndMinute,
      );
      if (selectedEndDateTime.isBefore(selectedStartDateTime)) {
        selectedStartDateTime =
            selectedEndDateTime.subtract(const Duration(hours: 1));
        selectedStartDay = selectedStartDateTime.day - 1;
        selectedStartMonth = selectedStartDateTime.month - 1;
        selectedStartYear = selectedStartDateTime.year;
        selectedStartHour = selectedStartDateTime.hour;
        selectedStartMinute = selectedStartDateTime.minute;
      }
    });
  }

  String _dateToString({
    required int month,
    required int day,
    required int year,
  }) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    String monthName = months.elementAt(month);
    int selectedDay = day + 1;
    return "$monthName $selectedDay, $year";
  }

  String _timeToString({required int hour, required int minute}) {
    String hourString = hour.toString();
    String minuteString = minute.toString();
    if (hour < 10) hourString = "0$hour";
    if (minute < 10) minuteString = "0$minute";
    return "$hourString:$minuteString";
  }
}
