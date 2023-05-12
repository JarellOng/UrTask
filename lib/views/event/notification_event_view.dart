import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/custom_notification_uot_enum.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
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
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // REMIND ME
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Remind me!"),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: remindMe,
                      onChanged: (value) {
                        setState(() {
                          remindMe = value;
                        });
                      },
                      // activeTrackColor: primary,
                      activeColor: primary,
                    ),
                  ),
                ],
              ),

              if (remindMe == true) ...[
                // TIME OF EVENT
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.timeOfEvent)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text("At time of event"),
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
                  const Text(
                    "Notifcation Type:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Alert
                  RadioListTile(
                    title: const Text("Alert"),
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
                    title: const Text("Push notification"),
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

                // 10 MINUTES BEFORE
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.tenMinsBefore)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text("10 minutes before"),
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
                  const Text(
                    "Notifcation Type:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Alert
                  RadioListTile(
                    title: const Text("Alert"),
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
                    title: const Text("Push notification"),
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

                // 1 HOUR BEFORE
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.hourBefore)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text("1 hour before"),
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
                  const Text(
                    "Notifcation Type:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Alert
                  RadioListTile(
                    title: const Text("Alert"),
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
                    title: const Text("Push notification"),
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

                // 1 DAY BEFORE
                ListTile(
                  leading: selectedNotifications
                          .containsKey(NotificationTime.dayBefore)
                      ? const Icon(Icons.radio_button_checked, color: primary)
                      : const Icon(Icons.radio_button_off),
                  title: const Text("1 day before"),
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
                  const Text(
                    "Notifcation Type:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Alert
                  RadioListTile(
                    title: const Text("Alert"),
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
                    title: const Text("Push notification"),
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
                        const Text("Custom"),
                      ],
                      if (selectedNotifications
                          .containsKey(NotificationTime.custom)) ...[
                        if (customNotificationScrollToggle == false) ...[
                          TextButton(
                            onPressed: () {
                              _customNotificationScrollOn();
                            },
                            child: Text(
                              _printCustomNotification(
                                amount: selectedCustomNotifcationAmount,
                                uot: selectedCustomNotifcationUot,
                              ),
                            ),
                          ),
                        ],
                        if (customNotificationScrollToggle == true) ...[
                          TextButton(
                            onPressed: () {
                              _customNotificationScrollOff();
                            },
                            child: const Text("..."),
                          ),
                        ],
                        // TextButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       if (customNotificationScrollToggle == true) {
                        //         _customNotificationScrollOff();
                        //       } else {
                        //         _customNotificationScrollOn();
                        //       }
                        //     });
                        //   },
                        //   child: Text(
                        //     _printCustomNotification(
                        //       amount: selectedCustomNotifcationAmount,
                        //       uot: selectedCustomNotifcationUot,
                        //     ),
                        //   ),
                        // )
                      ]
                    ],
                  ),
                  onTap: () {
                    if (selectedNotifications
                        .containsKey(NotificationTime.custom)) {
                      setState(() {
                        selectedNotifications.remove(NotificationTime.custom);
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
                ],

                if (selectedNotifications
                    .containsKey(NotificationTime.custom)) ...[
                  const Text(
                    "Notifcation Type:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Alert
                  RadioListTile(
                    title: const Text("Alert"),
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
                    title: const Text("Push notification"),
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

  String _printCustomNotification({required int amount, required int uot}) {
    if (amount == 0) {
      return "At time of event";
    }

    final uotName = CustomNotificationUOT.values.elementAt(uot).name;
    return "$amount $uotName before";
  }
}
