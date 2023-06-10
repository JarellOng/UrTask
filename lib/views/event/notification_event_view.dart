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
      onWillPop: () => _saveNotificationPreferences(),
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
                      SizedBox(width: 20),
                      Text("Remind me!", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: remindMe,
                      onChanged: (value) => _toggleNotification(toggle: value),
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
                  onTap: () => _selectNotificationTime(
                    time: NotificationTime.timeOfEvent,
                  ),
                ),

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
                  onTap: () => _selectNotificationTime(
                    time: NotificationTime.tenMinsBefore,
                  ),
                ),

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
                  onTap: () => _selectNotificationTime(
                    time: NotificationTime.hourBefore,
                  ),
                ),

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
                  onTap: () => _selectNotificationTime(
                    time: NotificationTime.dayBefore,
                  ),
                ),

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
                            onPressed: () => _customNotificationScrollOn(),
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
                          SizedBox(
                            width: 150,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 234, 220, 220),
                              ),
                              onPressed: () => _customNotificationScrollOff(),
                              child: const Text(
                                ". . .",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ]
                    ],
                  ),
                  onTap: () => _selectNotificationTime(
                    time: NotificationTime.custom,
                  ),
                ),
                if (customNotificationScrollToggle == true) ...[
                  CustomNotificationScrollView(
                    amount: customNotificationAmount,
                    uot: customNotificationUot,
                  ),
                  const SizedBox(height: 20)
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

  Future<bool> _saveNotificationPreferences() async {
    setState(() {
      if (selectedNotifications.isEmpty) {
        remindMe = false;
      }
      if (remindMe == false) {
        selectedNotifications.clear();
        selectedNotifications[NotificationTime.tenMinsBefore] =
            NotificationType.push;
      }
    });
    if (customNotificationScrollToggle == true) {
      _customNotificationScrollOff();
    }
    if (selectedNotifications.containsKey(NotificationTime.custom)) {
      if (selectedCustomNotifcationAmount == 0) {
        if (!selectedNotifications.containsKey(NotificationTime.timeOfEvent)) {
          _selectNotificationTime(time: NotificationTime.timeOfEvent);
          _selectNotificationType(
            time: NotificationTime.timeOfEvent,
            type: selectedNotifications[NotificationTime.custom]!,
          );
        }
        selectedNotifications.remove(NotificationTime.custom);
      } else if (selectedCustomNotifcationAmount == 10 &&
          selectedCustomNotifcationUot == 0) {
        if (!selectedNotifications
            .containsKey(NotificationTime.tenMinsBefore)) {
          _selectNotificationTime(time: NotificationTime.tenMinsBefore);
          _selectNotificationType(
            time: NotificationTime.tenMinsBefore,
            type: selectedNotifications[NotificationTime.custom]!,
          );
        }
        selectedNotifications.remove(NotificationTime.custom);
      } else if ((selectedCustomNotifcationAmount == 1 &&
              selectedCustomNotifcationUot == 1) ||
          (selectedCustomNotifcationAmount == 60 &&
              selectedCustomNotifcationUot == 0)) {
        if (!selectedNotifications.containsKey(NotificationTime.hourBefore)) {
          _selectNotificationTime(time: NotificationTime.hourBefore);
          _selectNotificationType(
            time: NotificationTime.hourBefore,
            type: selectedNotifications[NotificationTime.custom]!,
          );
        }
        selectedNotifications.remove(NotificationTime.custom);
      } else if ((selectedCustomNotifcationAmount == 1 &&
              selectedCustomNotifcationUot == 2) ||
          (selectedCustomNotifcationAmount == 24 &&
              selectedCustomNotifcationUot == 1)) {
        if (!selectedNotifications.containsKey(NotificationTime.dayBefore)) {
          _selectNotificationTime(time: NotificationTime.dayBefore);
          _selectNotificationType(
            time: NotificationTime.dayBefore,
            type: selectedNotifications[NotificationTime.custom]!,
          );
        }
        selectedNotifications.remove(NotificationTime.custom);
      }
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
  }

  void _toggleNotification({required bool toggle}) {
    setState(() {
      remindMe = toggle;
    });
  }

  void _selectNotificationTime({required NotificationTime time}) {
    if (selectedNotifications.containsKey(time)) {
      setState(() {
        selectedNotifications.remove(time);
        if (time == NotificationTime.custom &&
            customNotificationScrollToggle == true) {
          _customNotificationScrollOff();
        }
      });
    } else {
      setState(() {
        selectedNotifications[time] = NotificationType.push;
      });
    }
  }

  void _selectNotificationType({
    required NotificationTime time,
    required NotificationType type,
  }) {
    setState(() {
      selectedNotifications[time] = type;
    });
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
            customNotificationAmount.selectedItem % 61;
      } else if (selectedCustomNotifcationUot == 1) {
        selectedCustomNotifcationAmount =
            customNotificationAmount.selectedItem % 25;
      } else if (selectedCustomNotifcationUot == 2) {
        selectedCustomNotifcationAmount =
            customNotificationAmount.selectedItem % 366;
      }
    });
    setState(() {
      customNotificationScrollToggle = false;
    });
  }
}
