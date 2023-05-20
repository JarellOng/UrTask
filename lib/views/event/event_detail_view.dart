import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/custom_notification_uot_enum.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/services/notifications/notifications_model.dart';
import 'package:urtask/utilities/dialogs/categories_dialog.dart';
import 'package:urtask/utilities/dialogs/delete_dialog.dart';
import 'package:urtask/utilities/dialogs/discard_dialog.dart';
import 'package:urtask/utilities/dialogs/event_group_delete_dialog.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/dialogs/offline_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/date/date_scroll_view.dart';
import 'package:urtask/views/event/notification_event_view.dart';
import 'package:urtask/views/time/time_scroll_view.dart';

class EventDetailView extends StatefulWidget {
  final String eventId;
  final String? groupId;
  final String title;
  final Timestamp start;
  final Timestamp end;
  final bool important;
  final String? description;
  final String categoryId;
  final String categoryName;
  final String categoryHex;
  final Iterable<Notifications> notifications;

  const EventDetailView({
    super.key,
    required this.eventId,
    this.groupId,
    required this.title,
    required this.start,
    required this.end,
    required this.important,
    this.description,
    required this.categoryId,
    required this.categoryName,
    required this.categoryHex,
    required this.notifications,
  });

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  late final EventController _eventService;
  late final CategoryController _categoryService;
  late final ColorController _colorService;
  late final NotificationController _notificationService;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late String _eventId;
  late String? _eventGroupId;
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
  DateTime selectedStartDateTime = DateTime.now();
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
  DateTime selectedEndDateTime = DateTime.now();
  int selectedEndDay = DateTime.now().day - 1;
  int selectedEndMonth = DateTime.now().month - 1;
  int selectedEndYear = DateTime.now().year;
  int selectedEndHour = DateTime.now().hour + 2;
  int selectedEndMinute = 0;
  bool endDateScrollToggle = false;
  bool endTimeScrollToggle = false;

  // Important
  late bool important;

  // Category
  late String categoryId;
  late String categoryName;
  late String categoryHex;

  // Notification
  List<String> storedNotificationIds = [];
  bool notificationFlag = true;
  Map<NotificationTime, NotificationType> selectedNotifications = {};
  Map<int, CustomNotificationUOT>? selectedCustomNotification;

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _eventService = EventController();
    _eventTitle = TextEditingController();
    eventTitleFocus = FocusNode();
    _eventDescription = TextEditingController();
    eventDescriptionFocus = FocusNode();
    _categoryService = CategoryController();
    _colorService = ColorController();
    _notificationService = NotificationController();

    // Event
    _eventId = widget.eventId;
    _eventGroupId = widget.groupId;
    _eventTitle.text = widget.title;
    final start = widget.start.toDate();
    selectedStartDay = start.day - 1;
    selectedStartMonth = start.month - 1;
    selectedStartYear = start.year;
    selectedStartHour = start.hour;
    selectedStartMinute = start.minute;
    selectedStartDateTime = DateTime(
      selectedStartYear,
      selectedStartMonth + 1,
      selectedStartDay + 1,
      selectedStartHour,
      selectedStartMinute,
    );
    final end = widget.end.toDate();
    selectedEndDay = end.day - 1;
    selectedEndMonth = end.month - 1;
    selectedEndYear = end.year;
    selectedEndHour = end.hour;
    selectedEndMinute = end.minute;
    selectedEndDateTime = DateTime(
      selectedEndYear,
      selectedEndMonth + 1,
      selectedEndDay + 1,
      selectedEndHour,
      selectedEndMinute,
    );
    if (selectedStartHour == 0 &&
        selectedStartMinute == 0 &&
        selectedEndHour == 23 &&
        selectedEndMinute == 59) {
      allDay = true;
    }
    important = widget.important;
    _eventDescription.text = widget.description ?? "";

    // Category
    categoryId = widget.categoryId;
    categoryName = widget.categoryName;
    categoryHex = widget.categoryHex;

    // Notifications
    storedNotificationIds = widget.notifications.map((e) => e.id).toList();
    if (widget.notifications.isNotEmpty) {
      notificationFlag = true;
      for (var element in widget.notifications) {
        final difference =
            element.dateTime.toDate().difference(widget.start.toDate());
        if (difference.inSeconds == 0) {
          selectedNotifications[NotificationTime.timeOfEvent] = element.type;
        } else if (difference.inMinutes == -10) {
          selectedNotifications[NotificationTime.tenMinsBefore] = element.type;
        } else if (difference.inHours == -1) {
          selectedNotifications[NotificationTime.hourBefore] = element.type;
        } else if (difference.inDays == -1) {
          selectedNotifications[NotificationTime.dayBefore] = element.type;
        } else {
          selectedNotifications[NotificationTime.custom] = element.type;
          if (difference.inMinutes >= -60) {
            selectedCustomNotification = {
              difference.inMinutes.abs(): CustomNotificationUOT.minutes
            };
          } else if (difference.inHours >= -24) {
            selectedCustomNotification = {
              difference.inHours.abs(): CustomNotificationUOT.hours
            };
          } else if (difference.inDays >= -365) {
            selectedCustomNotification = {
              difference.inDays.abs(): CustomNotificationUOT.days
            };
          }
        }
      }
    } else {
      notificationFlag = false;
      selectedNotifications = {
        NotificationTime.tenMinsBefore: NotificationType.alert
      };
    }

    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _eventTitle.dispose();
    eventTitleFocus.dispose();
    _eventDescription.dispose();
    eventDescriptionFocus.dispose();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Event Detail",
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
          if (eventIsEdited) {
            final shouldDiscard = await showDiscardDialog(
              context,
              "Are you sure you want to discard your changes on this event?",
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
                            DateTimeHelper.dateToString(
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
                              DateTimeHelper.timeToString(
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
                            DateTimeHelper.dateToString(
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
                        if (endTimeScrollToggle == false) ...[
                          const Text(
                            "|",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
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
                              DateTimeHelper.timeToString(
                                hour: selectedEndDateTime.hour,
                                minute: selectedEndDateTime.minute,
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        if (endTimeScrollToggle == true) ...[
                          TextButton(
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
              ],
              if (endTimeScrollToggle == true) ...[
                // Time Scroll
                TimeScrollView(
                  hour: _eventEndHour,
                  minute: _eventEndMinute,
                ),
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
                          _eventService.printSelectedNotifications(
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DELETE BUTTON
            SizedBox(
              width: 175,
              child: TextButton(
                onPressed: () async {
                  if (_connectionStatus == ConnectivityResult.none) {
                    showOfflineDialog(
                      context: context,
                      text: "Please turn on your Internet connection",
                    );
                  } else {
                    final shouldDelete = await showDeleteDialog(
                      context,
                      "Are you sure you want to delete this event?",
                    );
                    if (shouldDelete) {
                      showLoadingDialog(context: context, text: "Deleting");
                      if (_eventGroupId != null && mounted) {
                        final shouldDeleteAllRepeatedEvents =
                            await showEventGroupDeleteDialog(context);
                        if (shouldDeleteAllRepeatedEvents == true) {
                          await _eventService.bulkDeleteByGroupId(
                              id: _eventGroupId!);
                          if (mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        } else if (shouldDeleteAllRepeatedEvents == false) {
                          await _eventService.delete(id: _eventId);
                          await _notificationService.bulkDelete(
                              ids: storedNotificationIds);
                          if (mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        }
                      } else {
                        await _eventService.delete(id: _eventId);
                        await _notificationService.bulkDelete(
                            ids: storedNotificationIds);
                        if (mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            // SAVE BUTTON
            SizedBox(
              width: 175,
              child: TextButton(
                onPressed: () async {
                  if (_connectionStatus == ConnectivityResult.none) {
                    showOfflineDialog(
                      context: context,
                      text: "Please turn on your Internet connection",
                    );
                  } else {
                    showLoadingDialog(context: context, text: "Saving");

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
                    final startTimestamp = allDay == true
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
                    final endTimestamp = allDay == true
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

                    // Update Event
                    await _eventService.update(
                      id: _eventId,
                      title: _eventTitle.text.isNotEmpty
                          ? _eventTitle.text
                          : "My Event",
                      categoryId: categoryId,
                      start: startTimestamp,
                      end: endTimestamp,
                      important: important,
                      description: _eventDescription.text,
                    );

                    // Update Notification
                    await _notificationService.bulkDelete(
                        ids: storedNotificationIds);
                    if (notificationFlag == true) {
                      selectedNotifications.forEach((key, value) {
                        if (key == NotificationTime.timeOfEvent) {
                          _notificationService.create(
                            eventId: _eventId,
                            dateTime: startTimestamp,
                            type: value.name,
                          );
                        } else if (key == NotificationTime.tenMinsBefore) {
                          _notificationService.create(
                            eventId: _eventId,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(const Duration(minutes: 10))),
                            type: value.name,
                          );
                        } else if (key == NotificationTime.hourBefore) {
                          _notificationService.create(
                            eventId: _eventId,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(const Duration(hours: 1))),
                            type: value.name,
                          );
                        } else if (key == NotificationTime.dayBefore) {
                          _notificationService.create(
                            eventId: _eventId,
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
                            eventId: _eventId,
                            dateTime: Timestamp.fromDate(startTimestamp
                                .toDate()
                                .subtract(customDuration)),
                            type: value.name,
                          );
                        }
                      });
                    }

                    if (mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 18),
                ),
              ),
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
}
