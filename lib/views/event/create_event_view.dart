import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/custom_notification_uot_enum.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/enums/repeat_duration_enum.dart';
import 'package:urtask/enums/repeat_type_enum.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/utilities/dialogs/categories_dialog.dart';
import 'package:urtask/utilities/dialogs/discard_dialog.dart';
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
  late final NotificationController _notificationService;

  late final TextEditingController _eventTitle;
  late final FocusNode eventTitleFocus;
  late final TextEditingController _eventDescription;
  late final FocusNode eventDescriptionFocus;
  bool eventIsEdited = false;

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
  int selectedStartHour = (DateTime.now().hour + 1) % 24;
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
  int selectedEndHour = (DateTime.now().hour + 2) % 24;
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
  int selectedRepeatTypeAmount = 0;
  int? selectedRepeatDurationAmount;
  DateTime? selectedRepeatDurationDate;

  // Notification
  bool notificationFlag = true;
  Map<NotificationTime, NotificationType> selectedNotifications = {
    NotificationTime.tenMinsBefore: NotificationType.alert
  };
  Map<int, CustomNotificationUOT>? selectedCustomNotification;

  @override
  void initState() {
    _eventService = EventController();
    _eventTitle = TextEditingController();
    eventTitleFocus = FocusNode();
    _eventDescription = TextEditingController();
    eventDescriptionFocus = FocusNode();
    _categoryService = CategoryController();
    _colorService = ColorController();
    _notificationService = NotificationController();
    selectedStartDay =
        selectedStartHour == 0 ? ++selectedStartDay : selectedStartDay;
    selectedEndDay = selectedEndHour == 0 || selectedEndHour == 1
        ? ++selectedEndDay
        : selectedEndDay;
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
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: () async {
          setState(() {
            eventTitleFocus.unfocus();
            eventDescriptionFocus.unfocus();
          });
          if (eventIsEdited ||
              _eventTitle.text.isNotEmpty ||
              _eventDescription.text.isNotEmpty) {
            final shouldDiscard = await showDiscardDialog(
              context,
              "Are you sure you want to discard this event?",
            );
            if (shouldDiscard) {
              if (mounted) {
                Navigator.of(context).pop();
                return true;
              }
            }
            return false;
          }
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TITLE
              SizedBox(
                width: 350,
                child: TextField(
                  controller: _eventTitle,
                  focusNode: eventTitleFocus,
                  enableSuggestions: false,
                  autocorrect: false,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Title",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.access_alarm),

              // ALL DAY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "All Day",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: allDay,
                      onChanged: (value) {
                        setState(() {
                          allDay = value;
                          if (allDay == true) {
                            selectedStartHour = 0;
                            selectedStartMinute = 0;
                            selectedEndHour = 23;
                            selectedEndMinute = 59;
                            selectedStartDateTime = DateTime(
                              selectedStartDateTime.year,
                              selectedStartDateTime.month,
                              selectedStartDateTime.day,
                              selectedStartHour,
                              selectedStartMinute,
                            );
                            selectedEndDateTime = DateTime(
                              selectedEndDateTime.year,
                              selectedEndDateTime.month,
                              selectedEndDateTime.day,
                              selectedEndHour,
                              selectedEndMinute,
                            );
                          }
                          if (startTimeScrollToggle == true) {
                            _startTimeScrollOff();
                          }
                          if (endTimeScrollToggle == true) {
                            _endTimeScrollOff();
                          }
                          eventIsEdited = true;
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
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Start",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                            eventIsEdited = true;
                          },
                          child: Text(
                            _dateToString(
                              month: selectedStartDateTime.month - 1,
                              day: selectedStartDateTime.day - 1,
                              year: selectedStartDateTime.year,
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                      if (startDateScrollToggle == true) ...[
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 234, 220, 220),
                          ),
                          onPressed: () {
                            _startDateScrollOff();
                          },
                          child: const SizedBox(
                            width: 110,
                            child: Text(
                              "...",
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],

                      // Time
                      if (allDay == false) ...[
                        const Text(
                          "|",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
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
                              eventIsEdited = true;
                            },
                            child: Text(
                              _timeToString(
                                hour: selectedStartDateTime.hour,
                                minute: selectedStartDateTime.minute,
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        if (startTimeScrollToggle == true) ...[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 234, 220, 220),
                            ),
                            onPressed: () {
                              _startTimeScrollOff();
                            },
                            child: const Text(
                              "...",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(width: 5),
                    ],
                  ),
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
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "End",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                            eventIsEdited = true;
                          },
                          child: Text(
                            _dateToString(
                              month: selectedEndDateTime.month - 1,
                              day: selectedEndDateTime.day - 1,
                              year: selectedEndDateTime.year,
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                      if (endDateScrollToggle == true) ...[
                        SizedBox(
                          width: 125,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 234, 220, 220),
                            ),
                            onPressed: () {
                              _endDateScrollOff();
                            },
                            child: const Text(
                              "...",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],

                      // Time
                      if (allDay == false) ...[
                        const Text(
                          "|",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
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
                              eventIsEdited = true;
                            },
                            child: Text(
                              _timeToString(
                                hour: selectedEndDateTime.hour,
                                minute: selectedEndDateTime.minute,
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        if (endTimeScrollToggle == true) ...[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 234, 220, 220),
                            ),
                            onPressed: () {
                              _endTimeScrollOff();
                            },
                            child: const Text(
                              "...",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
              if (endDateScrollToggle == true) ...[
                // Date Scroll
                DateScrollView(
                  day: _eventEndDay,
                  month: _eventEndMonth,
                  year: _eventEndYear,
                ),
                const SizedBox(height: 10),
              ],
              if (endTimeScrollToggle == true) ...[
                // Time Scroll
                TimeScrollView(
                  hour: _eventEndHour,
                  minute: _eventEndMinute,
                ),
                const SizedBox(height: 10),
              ],

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.warning_rounded),

              // IMPORTANT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Important",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: important,
                      onChanged: (value) {
                        setState(() {
                          important = value;
                          eventIsEdited = true;
                        });
                      },
                      activeColor: primary,
                    ),
                  ),
                ],
              ),

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.event),
              const SizedBox(height: 10),

              // CATEGORY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Category",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 175,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            categoryName,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          tileColor: HexColor.fromHex(categoryHex),
                          minLeadingWidth: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          visualDensity: const VisualDensity(vertical: -4),
                          onTap: () async {
                            setState(() {
                              eventTitleFocus.unfocus();
                              eventDescriptionFocus.unfocus();
                              eventIsEdited = true;
                            });
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
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.repeat),

              // REPEAT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Repeat",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            eventTitleFocus.unfocus();
                            eventDescriptionFocus.unfocus();
                            eventIsEdited = true;
                            if (startDateScrollToggle == true) {
                              _startDateScrollOff();
                            }
                            if (startTimeScrollToggle == true) {
                              _startTimeScrollOff();
                            }
                            if (endDateScrollToggle == true) {
                              _endDateScrollOff();
                            }
                            if (endTimeScrollToggle == true) {
                              _endTimeScrollOn();
                            }
                            if (selectedRepeatDurationDate != null &&
                                selectedRepeatDurationDate!.isBefore(
                                  DateTime(
                                    selectedStartDateTime.year,
                                    selectedStartDateTime.month,
                                    selectedStartDateTime.day,
                                  ),
                                )) {
                              selectedRepeatDurationDate = DateTime(
                                selectedStartDateTime.year,
                                selectedStartDateTime.month,
                                selectedStartDateTime.day,
                              ).add(const Duration(days: 1));
                            }
                          });
                          final repeatDetail = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RepeatEventView(
                                type: selectedRepeatType,
                                duration: selectedRepeatDuration,
                                typeAmount: selectedRepeatTypeAmount,
                                durationAmount: selectedRepeatDurationAmount,
                                durationDate: selectedRepeatDurationDate,
                                start: selectedStartDateTime,
                              ),
                            ),
                          );
                          setState(() {
                            selectedRepeatType = repeatDetail[0];
                            selectedRepeatDuration = repeatDetail[1];
                            selectedRepeatTypeAmount = repeatDetail[2];
                            if (selectedRepeatDuration ==
                                RepeatDuration.specificNumber) {
                              selectedRepeatDurationAmount = repeatDetail[3];
                              selectedRepeatDurationDate = null;
                            } else if (selectedRepeatDuration ==
                                RepeatDuration.until) {
                              selectedRepeatDurationDate = repeatDetail[3];
                              selectedRepeatDurationAmount = null;
                            }
                          });
                        },
                        child: Text(
                          _printSelectedRepeat(
                            type: selectedRepeatType,
                            typeAmount: selectedRepeatTypeAmount,
                            duration: selectedRepeatDuration,
                            durationAmount: selectedRepeatDurationAmount,
                            durationDate: selectedRepeatDurationDate,
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 5)
                    ],
                  ),
                ],
              ),

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.notifications_none),

              // NOTIFICATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Notification",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            eventTitleFocus.unfocus();
                            eventDescriptionFocus.unfocus();
                            eventIsEdited = true;
                          });
                          final notificationDetail = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationEventView(
                                flag: notificationFlag,
                                notifications: selectedNotifications,
                                customNotification: selectedCustomNotification,
                              ),
                            ),
                          );
                          setState(() {
                            notificationFlag = notificationDetail[0];
                            selectedNotifications = notificationDetail[1];
                            if (selectedNotifications
                                .containsKey(NotificationTime.custom)) {
                              final customNotificationMap =
                                  notificationDetail[2]
                                      as Map<int, CustomNotificationUOT>;
                              selectedCustomNotification = {
                                customNotificationMap.keys.first:
                                    customNotificationMap.values.first
                              };
                            }
                          });
                        },
                        child: Text(
                          _printSelectedNotifications(
                            flag: notificationFlag,
                            selectedNotifications: selectedNotifications,
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),
              const SizedBox(height: 10),
              const Icon(Icons.event_note),

              // DESCRIPTION
              SizedBox(
                width: 350,
                child: TextField(
                  controller: _eventDescription,
                  focusNode: eventDescriptionFocus,
                  enableSuggestions: false,
                  autocorrect: false,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Description",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // SAVE BUTTON
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        child: TextButton(
          onPressed: () async {
            if (startDateScrollToggle == true) {
              _startDateScrollOff();
            }
            if (startTimeScrollToggle == true) {
              _startTimeScrollOff();
            }
            if (endDateScrollToggle == true) {
              _endDateScrollOff();
            }
            if (endTimeScrollToggle == true) {
              _endTimeScrollOff();
            }
            Timestamp startTimestamp = allDay == true
                ? Timestamp.fromDate(
                    DateTime(
                      selectedStartDateTime.year,
                      selectedStartDateTime.month,
                      selectedStartDateTime.day,
                    ),
                  )
                : Timestamp.fromDate(
                    DateTime(
                      selectedStartDateTime.year,
                      selectedStartDateTime.month,
                      selectedStartDateTime.day,
                      selectedStartDateTime.hour,
                      selectedStartDateTime.minute,
                    ),
                  );
            Timestamp endTimestamp = allDay == true
                ? Timestamp.fromDate(
                    DateTime(
                      selectedEndDateTime.year,
                      selectedEndDateTime.month,
                      selectedEndDateTime.day,
                      23,
                      59,
                    ),
                  )
                : Timestamp.fromDate(
                    DateTime(
                      selectedEndDateTime.year,
                      selectedEndDateTime.month,
                      selectedEndDateTime.day,
                      selectedEndDateTime.hour,
                      selectedEndDateTime.minute,
                    ),
                  );

            // Create Event
            final eventGroupId = selectedRepeatType != RepeatType.noRepeat
                ? "repeat${DateTime.now()}"
                : null;
            final createdEvent = await _eventService.create(
              title:
                  _eventTitle.text.isNotEmpty ? _eventTitle.text : "My Event",
              categoryId: categoryId,
              groupId: eventGroupId,
              start: startTimestamp,
              end: endTimestamp,
              important: important,
              description: _eventDescription.text,
            );

            // Create Notifications
            if (notificationFlag == true) {
              selectedNotifications.forEach(
                (key, value) {
                  if (key == NotificationTime.timeOfEvent) {
                    _notificationService.create(
                      eventId: createdEvent,
                      dateTime: startTimestamp,
                      type: value.name,
                    );
                  } else if (key == NotificationTime.tenMinsBefore) {
                    _notificationService.create(
                      eventId: createdEvent,
                      dateTime: Timestamp.fromDate(startTimestamp
                          .toDate()
                          .subtract(const Duration(minutes: 10))),
                      type: value.name,
                    );
                  } else if (key == NotificationTime.hourBefore) {
                    _notificationService.create(
                      eventId: createdEvent,
                      dateTime: Timestamp.fromDate(startTimestamp
                          .toDate()
                          .subtract(const Duration(hours: 1))),
                      type: value.name,
                    );
                  } else if (key == NotificationTime.dayBefore) {
                    _notificationService.create(
                      eventId: createdEvent,
                      dateTime: Timestamp.fromDate(startTimestamp
                          .toDate()
                          .subtract(const Duration(days: 1))),
                      type: value.name,
                    );
                  } else if (key == NotificationTime.custom) {
                    final customAmount = selectedCustomNotification!.keys.first;
                    late Duration customDuration;
                    if (selectedCustomNotification!.values.first ==
                        CustomNotificationUOT.minutes) {
                      customDuration = Duration(minutes: customAmount);
                    } else if (selectedCustomNotification!.values.first ==
                        CustomNotificationUOT.hours) {
                      customDuration = Duration(hours: customAmount);
                    } else if (selectedCustomNotification!.values.first ==
                        CustomNotificationUOT.days) {
                      customDuration = Duration(days: customAmount);
                    }
                    _notificationService.create(
                      eventId: createdEvent,
                      dateTime: Timestamp.fromDate(
                          startTimestamp.toDate().subtract(customDuration)),
                      type: value.name,
                    );
                  }
                },
              );
            }

            // Create Duplicate Events
            if (selectedRepeatType != RepeatType.noRepeat) {
              Duration? repeatDurationArithmetic;
              if (selectedRepeatType == RepeatType.perDay) {
                repeatDurationArithmetic =
                    Duration(days: selectedRepeatTypeAmount);
              } else if (selectedRepeatType == RepeatType.perWeek) {
                repeatDurationArithmetic =
                    Duration(days: 7 * selectedRepeatTypeAmount);
              }

              if (selectedRepeatDuration == RepeatDuration.specificNumber) {
                for (var i = 0; i < selectedRepeatDurationAmount!; i++) {
                  if (repeatDurationArithmetic != null) {
                    startTimestamp = Timestamp.fromDate(
                        startTimestamp.toDate().add(repeatDurationArithmetic));
                    endTimestamp = Timestamp.fromDate(
                        endTimestamp.toDate().add(repeatDurationArithmetic));
                  } else {
                    final startDateTime = startTimestamp.toDate();
                    final endDateTime = endTimestamp.toDate();
                    if (selectedRepeatType == RepeatType.perMonth) {
                      startTimestamp = Timestamp.fromDate(
                        DateTime(
                          startDateTime.year,
                          startDateTime.month + selectedRepeatTypeAmount,
                          startDateTime.day,
                          startDateTime.hour,
                          startDateTime.minute,
                        ),
                      );
                      endTimestamp = Timestamp.fromDate(
                        DateTime(
                          endDateTime.year,
                          endDateTime.month + selectedRepeatTypeAmount,
                          endDateTime.day,
                          endDateTime.hour,
                          endDateTime.minute,
                        ),
                      );
                    } else if (selectedRepeatType == RepeatType.perYear) {
                      startTimestamp = Timestamp.fromDate(
                        DateTime(
                          startDateTime.year + selectedRepeatTypeAmount,
                          startDateTime.month,
                          startDateTime.day,
                          startDateTime.hour,
                          startDateTime.minute,
                        ),
                      );
                      endTimestamp = Timestamp.fromDate(
                        DateTime(
                          endDateTime.year + selectedRepeatTypeAmount,
                          endDateTime.month,
                          endDateTime.day,
                          endDateTime.hour,
                          endDateTime.minute,
                        ),
                      );
                    }
                  }
                  final createdRepeatEvent = await _eventService.create(
                    title: _eventTitle.text.isNotEmpty
                        ? _eventTitle.text
                        : "My Event",
                    categoryId: categoryId,
                    groupId: eventGroupId,
                    start: startTimestamp,
                    end: endTimestamp,
                    important: important,
                    description: _eventDescription.text,
                  );

                  // Create Notifications
                  if (notificationFlag == true) {
                    selectedNotifications.forEach((key, value) {
                      if (key == NotificationTime.timeOfEvent) {
                        _notificationService.create(
                          eventId: createdRepeatEvent,
                          dateTime: startTimestamp,
                          type: value.name,
                        );
                      } else if (key == NotificationTime.tenMinsBefore) {
                        _notificationService.create(
                          eventId: createdRepeatEvent,
                          dateTime: Timestamp.fromDate(startTimestamp
                              .toDate()
                              .subtract(const Duration(minutes: 10))),
                          type: value.name,
                        );
                      } else if (key == NotificationTime.hourBefore) {
                        _notificationService.create(
                          eventId: createdRepeatEvent,
                          dateTime: Timestamp.fromDate(startTimestamp
                              .toDate()
                              .subtract(const Duration(hours: 1))),
                          type: value.name,
                        );
                      } else if (key == NotificationTime.dayBefore) {
                        _notificationService.create(
                          eventId: createdRepeatEvent,
                          dateTime: Timestamp.fromDate(startTimestamp
                              .toDate()
                              .subtract(const Duration(days: 1))),
                          type: value.name,
                        );
                      } else if (key == NotificationTime.custom) {
                        final customAmount =
                            selectedCustomNotification!.keys.first;
                        late Duration customDuration;
                        if (selectedCustomNotification!.values.first ==
                            CustomNotificationUOT.minutes) {
                          customDuration = Duration(minutes: customAmount);
                        } else if (selectedCustomNotification!.values.first ==
                            CustomNotificationUOT.hours) {
                          customDuration = Duration(hours: customAmount);
                        } else if (selectedCustomNotification!.values.first ==
                            CustomNotificationUOT.days) {
                          customDuration = Duration(days: customAmount);
                        }
                        _notificationService.create(
                          eventId: createdRepeatEvent,
                          dateTime: Timestamp.fromDate(
                              startTimestamp.toDate().subtract(customDuration)),
                          type: value.name,
                        );
                      }
                    });
                  }
                }
              } else if (selectedRepeatDuration == RepeatDuration.until) {
                while (!startTimestamp
                    .toDate()
                    .isAfter(selectedRepeatDurationDate!.add(
                      const Duration(
                        hours: 23,
                        minutes: 59,
                      ),
                    ))) {
                  if (repeatDurationArithmetic != null) {
                    startTimestamp = Timestamp.fromDate(
                        startTimestamp.toDate().add(repeatDurationArithmetic));
                    endTimestamp = Timestamp.fromDate(
                        endTimestamp.toDate().add(repeatDurationArithmetic));
                  } else {
                    final startDateTime = startTimestamp.toDate();
                    final endDateTime = endTimestamp.toDate();
                    if (selectedRepeatType == RepeatType.perMonth) {
                      startTimestamp = Timestamp.fromDate(
                        DateTime(
                          startDateTime.year,
                          startDateTime.month + selectedRepeatTypeAmount,
                          startDateTime.day,
                          startDateTime.hour,
                          startDateTime.minute,
                        ),
                      );
                      endTimestamp = Timestamp.fromDate(
                        DateTime(
                          endDateTime.year,
                          endDateTime.month + selectedRepeatTypeAmount,
                          endDateTime.day,
                          endDateTime.hour,
                          endDateTime.minute,
                        ),
                      );
                    } else if (selectedRepeatType == RepeatType.perYear) {
                      startTimestamp = Timestamp.fromDate(
                        DateTime(
                          startDateTime.year + selectedRepeatTypeAmount,
                          startDateTime.month,
                          startDateTime.day,
                          startDateTime.hour,
                          startDateTime.minute,
                        ),
                      );
                      endTimestamp = Timestamp.fromDate(
                        DateTime(
                          endDateTime.year + selectedRepeatTypeAmount,
                          endDateTime.month,
                          endDateTime.day,
                          endDateTime.hour,
                          endDateTime.minute,
                        ),
                      );
                    }
                  }
                  if (startTimestamp
                      .toDate()
                      .isAfter(selectedRepeatDurationDate!.add(
                        const Duration(
                          hours: 23,
                          minutes: 59,
                        ),
                      ))) break;
                  final createdRepeatEvent = await _eventService.create(
                    title: _eventTitle.text.isNotEmpty
                        ? _eventTitle.text
                        : "My Event",
                    categoryId: categoryId,
                    groupId: eventGroupId,
                    start: startTimestamp,
                    end: endTimestamp,
                    important: important,
                    description: _eventDescription.text,
                  );
                  // Create Notifications
                  if (notificationFlag == true) {
                    selectedNotifications.forEach(
                      (key, value) {
                        if (key == NotificationTime.timeOfEvent) {
                          _notificationService.create(
                            eventId: createdRepeatEvent,
                            dateTime: startTimestamp,
                            type: value.name,
                          );
                        } else if (key == NotificationTime.tenMinsBefore) {
                          _notificationService.create(
                            eventId: createdRepeatEvent,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(const Duration(minutes: 10))),
                            type: value.name,
                          );
                        } else if (key == NotificationTime.hourBefore) {
                          _notificationService.create(
                            eventId: createdRepeatEvent,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(const Duration(hours: 1))),
                            type: value.name,
                          );
                        } else if (key == NotificationTime.dayBefore) {
                          _notificationService.create(
                            eventId: createdRepeatEvent,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(const Duration(days: 1))),
                            type: value.name,
                          );
                        } else if (key == NotificationTime.custom) {
                          final customAmount =
                              selectedCustomNotification!.keys.first;
                          late Duration customDuration;
                          if (selectedCustomNotification!.values.first ==
                              CustomNotificationUOT.minutes) {
                            customDuration = Duration(minutes: customAmount);
                          } else if (selectedCustomNotification!.values.first ==
                              CustomNotificationUOT.hours) {
                            customDuration = Duration(hours: customAmount);
                          } else if (selectedCustomNotification!.values.first ==
                              CustomNotificationUOT.days) {
                            customDuration = Duration(days: customAmount);
                          }
                          _notificationService.create(
                            eventId: createdRepeatEvent,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(customDuration)),
                            type: value.name,
                          );
                        }
                      },
                    );
                  }
                }
              }
            }

            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            "Save",
            style: TextStyle(fontSize: 18),
          ),
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
      if (selectedStartDateTime.isAfter(selectedEndDateTime) ||
          selectedStartDateTime.isAtSameMomentAs(selectedEndDateTime)) {
        if (allDay == false) {
          selectedEndDateTime =
              selectedStartDateTime.add(const Duration(hours: 1));
        } else {
          selectedEndDateTime = DateTime(
            selectedStartDateTime.year,
            selectedStartDateTime.month,
            selectedStartDateTime.day,
            23,
            59,
          );
        }
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
      if (selectedStartDateTime.isAfter(selectedEndDateTime) ||
          selectedStartDateTime.isAtSameMomentAs(selectedEndDateTime)) {
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
      if (selectedEndDateTime.isBefore(selectedStartDateTime) ||
          selectedEndDateTime.isAtSameMomentAs(selectedStartDateTime)) {
        if (allDay == false) {
          selectedStartDateTime =
              selectedEndDateTime.subtract(const Duration(hours: 1));
        } else {
          selectedStartDateTime = DateTime(
            selectedEndDateTime.year,
            selectedEndDateTime.month,
            selectedEndDateTime.day,
            0,
            0,
          );
        }
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
      if (selectedEndDateTime.isBefore(selectedStartDateTime) ||
          selectedEndDateTime.isAtSameMomentAs(selectedStartDateTime)) {
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

  String _printSelectedRepeat({
    required RepeatType type,
    required int typeAmount,
    required RepeatDuration duration,
    int? durationAmount,
    DateTime? durationDate,
  }) {
    String repeatString = "";

    if (type == RepeatType.noRepeat) {
      repeatString += "Don't repeat";
    } else if (type == RepeatType.perDay) {
      if (typeAmount <= 1) {
        repeatString += "Everyday";
      } else {
        repeatString += "Every $typeAmount days";
      }
    } else if (type == RepeatType.perMonth) {
      if (typeAmount <= 1) {
        repeatString += "Every month";
      } else {
        repeatString += "Every $typeAmount months";
      }
    } else if (type == RepeatType.perWeek) {
      if (typeAmount <= 1) {
        repeatString += "Every week";
      } else {
        repeatString += "Every $typeAmount weeks";
      }
    } else if (type == RepeatType.perYear) {
      if (typeAmount <= 1) {
        repeatString += "Every year";
      } else {
        repeatString += "Every $typeAmount years";
      }
    }

    if (durationAmount != null) {
      if (durationAmount <= 1) {
        repeatString += " (once)";
      } else {
        repeatString += " ($durationAmount times)";
      }
    } else if (durationDate != null) {
      final day = durationDate.day - 1;
      final month = durationDate.month - 1;
      final year = durationDate.year;
      repeatString += " until ${_dateToString(
        month: month,
        day: day,
        year: year,
      )}";
    }
    return repeatString;
  }

  String _printSelectedNotifications({
    required bool flag,
    required Map<NotificationTime, NotificationType> selectedNotifications,
  }) {
    String notificationString = "";
    if (flag == false) {
      notificationString += "No notifications";
    } else {
      final notificationAmount = selectedNotifications.values.length;
      if (notificationAmount <= 1) {
        notificationString += "1 notification";
      } else {
        notificationString += "$notificationAmount notifications";
      }
    }

    return notificationString;
  }
}
