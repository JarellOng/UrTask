import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';

class NotificationEventView extends StatefulWidget {
  const NotificationEventView({super.key});

  @override
  State<NotificationEventView> createState() => _NotificationEventViewState();
}

class _NotificationEventViewState extends State<NotificationEventView> {
  bool remindMe = true;
  Map<NotificationTime, NotificationType> selectedNotifications = {
    NotificationTime.tenMinsBefore: NotificationType.alert
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      selectedNotifications.remove(NotificationTime.hourBefore);
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
                      selectedNotifications.remove(NotificationTime.dayBefore);
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
                  groupValue: selectedNotifications[NotificationTime.dayBefore],
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
                  groupValue: selectedNotifications[NotificationTime.dayBefore],
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
                leading:
                    selectedNotifications.containsKey(NotificationTime.custom)
                        ? const Icon(Icons.radio_button_checked, color: primary)
                        : const Icon(Icons.radio_button_off),
                title: const Text("Custom"),
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
    );
  }
}
