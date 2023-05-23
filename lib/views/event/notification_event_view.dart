import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/custom_notification_uot_enum.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/views/notification/custom_notification_view.dart';

class NotificationEventView extends StatefulWidget {
  final bool flag;
  final Map<NotificationTime, NotificationType> notifications;
  final Map<int, CustomNotificationUOT>? customNotification;

  const NotificationEventView({
    super.key,
    required this.flag,
    required this.notifications,
    this.customNotification,
  });

  @override
  State<NotificationEventView> createState() => _NotificationEventViewState();
}

class _NotificationEventViewState extends State<NotificationEventView> {
  late final EventController _eventService;
  late bool remindMe;
  late Map<NotificationTime, NotificationType> selectedNotifications;
  late Map<int, CustomNotificationUOT>? customNotification;
  late FixedExtentScrollController customNotificationAmount;
  late FixedExtentScrollController customNotificationUot;
  late int selectedCustomNotifcationAmount;
  late int selectedCustomNotifcationUot;
  bool customNotificationScrollToggle = false;

  @override
  void initState() {
    _eventService = EventController();
    remindMe = widget.flag;
    selectedNotifications = widget.notifications;
    customNotification = widget.customNotification;
    if (widget.customNotification != null) {
      selectedCustomNotifcationAmount = widget.customNotification!.keys.first;
      selectedCustomNotifcationUot =
          widget.customNotification!.values.first.index;
    } else {
      selectedCustomNotifcationAmount = 5;
      selectedCustomNotifcationUot = 0;
    }
    customNotificationAmount = FixedExtentScrollController(initialItem: 5);
    customNotificationUot = FixedExtentScrollController(initialItem: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          if (selectedNotifications.isEmpty) {
            remindMe = false;
          }
          if (remindMe == false) {
            selectedNotifications.clear();
            selectedNotifications[NotificationTime.tenMinsBefore] =
                NotificationType.alert;
          }
        });
        if (customNotificationScrollToggle == true) {
          _customNotificationScrollOff();
        }
        if (selectedNotifications.containsKey(NotificationTime.custom)) {
          Navigator.of(context).pop([
            remindMe,
            selectedNotifications,
            {
              selectedCustomNotifcationAmount: CustomNotificationUOT.values
                  .elementAt(selectedCustomNotifcationUot)
            }
          ]);
          return true;
        }
        Navigator.of(context).pop([remindMe, selectedNotifications]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: const Text(
            "Event Notification",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // REMIND ME
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Remind me!",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: remindMe,
                      onChanged: (value) {
                        setState(() {
                          remindMe = value;
                        });
                      },
                      activeColor: primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (remindMe == true) ...[
                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // TIME OF EVENT
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.timeOfEvent)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text(
                    "At time of event",
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    if (selectedNotifications
                        .containsKey(NotificationTime.timeOfEvent)) {
                      setState(() {
                        selectedNotifications
                            .remove(NotificationTime.timeOfEvent);
                      });
                    } else {
                      setState(() {
                        selectedNotifications[NotificationTime.timeOfEvent] =
                            NotificationType.alert;
                      });
                    }
                  },
                ),
                if (selectedNotifications
                    .containsKey(NotificationTime.timeOfEvent)) ...[
                  const DottedLine(lineLength: 350),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Notifcation Type:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Alert
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Alert",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.alert,
                    groupValue:
                        selectedNotifications[NotificationTime.timeOfEvent],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.timeOfEvent] =
                            NotificationType.alert;
                      });
                    },
                  ),

                  // Push
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Push notification",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.push,
                    groupValue:
                        selectedNotifications[NotificationTime.timeOfEvent],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.timeOfEvent] =
                            NotificationType.push;
                      });
                    },
                  ),
                ],

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // 10 MINUTES BEFORE
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.tenMinsBefore)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text(
                    "10 minutes before",
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    if (selectedNotifications
                        .containsKey(NotificationTime.tenMinsBefore)) {
                      setState(() {
                        selectedNotifications
                            .remove(NotificationTime.tenMinsBefore);
                      });
                    } else {
                      setState(() {
                        selectedNotifications[NotificationTime.tenMinsBefore] =
                            NotificationType.alert;
                      });
                    }
                  },
                ),
                if (selectedNotifications
                    .containsKey(NotificationTime.tenMinsBefore)) ...[
                  const DottedLine(lineLength: 350),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Notifcation Type:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Alert
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Alert",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.alert,
                    groupValue:
                        selectedNotifications[NotificationTime.tenMinsBefore],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.tenMinsBefore] =
                            NotificationType.alert;
                      });
                    },
                  ),

                  // Push
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Push notification",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.push,
                    groupValue:
                        selectedNotifications[NotificationTime.tenMinsBefore],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.tenMinsBefore] =
                            NotificationType.push;
                      });
                    },
                  ),
                ],

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // 1 HOUR BEFORE
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.hourBefore)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text(
                    "1 hour before",
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    if (selectedNotifications
                        .containsKey(NotificationTime.hourBefore)) {
                      setState(() {
                        selectedNotifications
                            .remove(NotificationTime.hourBefore);
                      });
                    } else {
                      setState(() {
                        selectedNotifications[NotificationTime.hourBefore] =
                            NotificationType.alert;
                      });
                    }
                  },
                ),
                if (selectedNotifications
                    .containsKey(NotificationTime.hourBefore)) ...[
                  const DottedLine(lineLength: 350),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Notifcation Type:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Alert
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Alert",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.alert,
                    groupValue:
                        selectedNotifications[NotificationTime.hourBefore],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.hourBefore] =
                            NotificationType.alert;
                      });
                    },
                  ),

                  // Push
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Push notification",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.push,
                    groupValue:
                        selectedNotifications[NotificationTime.hourBefore],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.hourBefore] =
                            NotificationType.push;
                      });
                    },
                  ),
                ],

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // 1 DAY BEFORE
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.dayBefore)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text(
                    "1 day before",
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    if (selectedNotifications
                        .containsKey(NotificationTime.dayBefore)) {
                      setState(() {
                        selectedNotifications
                            .remove(NotificationTime.dayBefore);
                      });
                    } else {
                      setState(() {
                        selectedNotifications[NotificationTime.dayBefore] =
                            NotificationType.alert;
                      });
                    }
                  },
                ),
                if (selectedNotifications
                    .containsKey(NotificationTime.dayBefore)) ...[
                  const DottedLine(lineLength: 350),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Notifcation Type:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Alert
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Alert",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.alert,
                    groupValue:
                        selectedNotifications[NotificationTime.dayBefore],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.dayBefore] =
                            NotificationType.alert;
                      });
                    },
                  ),

                  // Push
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Push notification",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.push,
                    groupValue:
                        selectedNotifications[NotificationTime.dayBefore],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.dayBefore] =
                            NotificationType.push;
                      });
                    },
                  ),
                ],

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // CUSTOM
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.custom)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: Row(
                    children: [
                      if (!selectedNotifications
                          .containsKey(NotificationTime.custom)) ...[
                        const Text(
                          "Custom",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                      if (selectedNotifications
                          .containsKey(NotificationTime.custom)) ...[
                        if (customNotificationScrollToggle == false) ...[
                          TextButton(
                            onPressed: () {
                              _customNotificationScrollOn();
                            },
                            child: Text(
                              _eventService.printCustomNotification(
                                amount: selectedCustomNotifcationAmount,
                                uot: selectedCustomNotifcationUot,
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        if (customNotificationScrollToggle == true) ...[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 234, 220, 220),
                            ),
                            onPressed: () {
                              _customNotificationScrollOff();
                            },
                            child: const Text(
                              ". . .",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ]
                    ],
                  ),
                  onTap: () {
                    if (selectedNotifications
                        .containsKey(NotificationTime.custom)) {
                      setState(() {
                        selectedNotifications.remove(NotificationTime.custom);
                        if (customNotificationScrollToggle == true) {
                          _customNotificationScrollOff();
                        }
                      });
                    } else {
                      setState(() {
                        selectedNotifications[NotificationTime.custom] =
                            NotificationType.alert;
                      });
                    }
                  },
                ),
                if (customNotificationScrollToggle == true) ...[
                  CustomNotificationScrollView(
                    amount: customNotificationAmount,
                    uot: customNotificationUot,
                  ),
                  const SizedBox(height: 20)
                ],

                if (selectedNotifications
                    .containsKey(NotificationTime.custom)) ...[
                  const DottedLine(lineLength: 350),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text(
                        "Notifcation Type:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Alert
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Alert",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.alert,
                    groupValue: selectedNotifications[NotificationTime.custom],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.custom] =
                            NotificationType.alert;
                      });
                    },
                  ),

                  // Push
                  RadioListTile(
                    dense: true,
                    title: const Text(
                      "Push notification",
                      style: TextStyle(fontSize: 18),
                    ),
                    value: NotificationType.push,
                    groupValue: selectedNotifications[NotificationTime.custom],
                    onChanged: (value) {
                      setState(() {
                        selectedNotifications[NotificationTime.custom] =
                            NotificationType.push;
                      });
                    },
                  ),
                ],

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _customNotificationScrollOn() {
    setState(() {
      customNotificationAmount = FixedExtentScrollController(
          initialItem: selectedCustomNotifcationAmount);
      customNotificationUot = FixedExtentScrollController(
          initialItem: selectedCustomNotifcationUot);
    });
    setState(() {
      customNotificationScrollToggle = true;
    });
  }

  void _customNotificationScrollOff() {
    setState(() {
      selectedCustomNotifcationUot = customNotificationUot.selectedItem;
      if (selectedCustomNotifcationUot == 0) {
        selectedCustomNotifcationAmount =
            customNotificationAmount.selectedItem % 62;
      } else if (selectedCustomNotifcationUot == 1) {
        selectedCustomNotifcationAmount =
            customNotificationAmount.selectedItem % 26;
      } else if (selectedCustomNotifcationUot == 2) {
        selectedCustomNotifcationAmount =
            customNotificationAmount.selectedItem % 367;
      }
    });
    setState(() {
      customNotificationScrollToggle = false;
    });
  }
}
