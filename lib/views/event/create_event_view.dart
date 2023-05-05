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
  int selectedStartDay = DateTime.now().day - 1;
  int selectedStartMonth = DateTime.now().month - 1;
  int selectedStartYear = DateTime.now().year;
  int selectedStartHour = DateTime.now().hour + 1;
  int selectedStartMinute = 0;
  bool startDateScrollToggle = false;
  bool startTimeScrollToggle = false;

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
    super.initState();
  }

  @override
  void dispose() {
    _eventTitle.dispose();
    _eventDescription.dispose();
    _eventStartDay.dispose();
    _eventStartMonth.dispose();
    _eventStartYear.dispose();
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
                        _startTimeScrollOff();
                      });
                    },
                    // activeTrackColor: primary,
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
                      _startDateScrollOn();
                      _startTimeScrollOff();
                    },
                    child: Text(
                      _dateToString(
                        month: selectedStartMonth,
                        day: selectedStartDay,
                        year: selectedStartYear,
                      ),
                    ),
                  )
                ],
                if (startDateScrollToggle == true) ...[
                  TextButton(
                    onPressed: () {
                      _startDateScrollOff();
                    },
                    child: const Text("..."),
                  )
                ],

                // Time
                if (allDay == false) ...[
                  if (startTimeScrollToggle == false) ...[
                    TextButton(
                      onPressed: () {
                        _startTimeScrollOn();
                        _startDateScrollOff();
                      },
                      child: Text(
                        _timeToString(
                          hour: selectedStartHour,
                          minute: selectedStartMinute,
                        ),
                      ),
                    )
                  ],
                  if (startTimeScrollToggle == true) ...[
                    TextButton(
                      onPressed: () {
                        _startTimeScrollOff();
                      },
                      child: const Text("..."),
                    )
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
            if (allDay == false && startTimeScrollToggle == true) ...[
              // Time Scroll
              TimeScrollView(
                hour: _eventStartHour,
                minute: _eventStartMinute,
              ),
            ],

            // END
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("End"),
              ],
            ),

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
      startTimeScrollToggle = false;
    });
    setState(() {
      selectedStartHour = _eventStartHour.selectedItem % 25;
      selectedStartMinute = _eventStartMinute.selectedItem % 60;
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
