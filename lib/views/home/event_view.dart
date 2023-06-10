import 'package:flutter/material.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/services/notifications/notifications_model.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/event/event_detail_view.dart';

class EventView extends StatefulWidget {
  final DateTime selectedDay;
  final List<String> myList;
  const EventView({super.key, required this.selectedDay, required this.myList});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late final EventController _eventService;
  late final CategoryController _categoryController;
  late final ColorController _colorService;
  late final NotificationController _notificationService;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    _eventService = EventController();
    _categoryController = CategoryController();
    _colorService = ColorController();
    _notificationService = NotificationController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _eventService.getByDate(
          dateTime: widget.selectedDay, excludedCategoryIds: widget.myList),
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
                        onTap: () => _setupEventDetailDataAndPush(event: event),
                        leading: Transform.translate(
                          offset: const Offset(-8, -6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
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
                              const VerticalDivider(color: Colors.black45),
                            ],
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Align(
                          alignment: Alignment.topLeft,
                          child: FutureBuilder(
                            future:
                                _categoryController.get(id: event.categoryId),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.done:
                                  if (snapshot.hasData) {
                                    final category =
                                        snapshot.data as Categories;
                                    //print(widget.myList);
                                    return FutureBuilder(
                                        future: _colorService.get(
                                            id: category.colorId),
                                        builder: (context, snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.done:
                                              if (snapshot.hasData) {
                                                final color = snapshot.data
                                                    as color_model.Colors;
                                                return Chip(
                                                  backgroundColor:
                                                      HexColor.fromHex(
                                                          color.hex),
                                                  label: Text(
                                                    category.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
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
      month: widget.selectedDay.month,
      day: widget.selectedDay.day,
      year: widget.selectedDay.year,
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
      month: widget.selectedDay.month,
      day: widget.selectedDay.day,
      year: widget.selectedDay.year,
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
}
