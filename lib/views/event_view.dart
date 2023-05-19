import 'package:flutter/material.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/services/notifications/notifications_model.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/event/event_detail_view.dart';

class EventView extends StatefulWidget {
  final DateTime selectedDay;
  const EventView({super.key, required this.selectedDay});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late final EventController _eventService;
  late final CategoryController _categoryController;
  late final ColorController _colorService;
  late final NotificationController _notificationService;

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
      stream: _eventService.getByDate(dateTime: widget.selectedDay),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (snapshot.hasData) {
              final events = snapshot.data as Iterable<Events>;
              return ListView.separated(
                padding: const EdgeInsets.all(
                  12,
                ),
                shrinkWrap: true,
                itemCount: events.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  final event = events.elementAt(index);
                  return ListTile(
                    onTap: () async {
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
                      final notifications =
                          futures[1] as Iterable<Notifications>;
                      if (mounted) {
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
                    },
                    leading: Transform.translate(
                        offset: Offset(-8, -6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Column(children: [
                                  Text("17.00",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600)),
                                  Text("19.00",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black45))
                                ]),
                              ),
                            ),
                            VerticalDivider(color: Colors.black45),
                          ],
                        )),
                    title: Text(event.title,
                        style: TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
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
                                                    label: Text(category.name,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)));
                                              } else {
                                                return const CircularProgressIndicator();
                                              }
                                            default:
                                              return const CircularProgressIndicator();
                                          }
                                        });
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                default:
                                  return const CircularProgressIndicator();
                              }
                            })),
                    horizontalTitleGap: -2,
                    trailing: event.important
                        ? Icon(Icons.error_outlined,
                            size: 32, color: Colors.red)
                        : null,
                    shape: Border(bottom: BorderSide(color: Colors.black26)),
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

  Future<Categories> setupCategory({required String id}) async {
    final category = await _categoryController.get(id: id);
    return category;
  }

  Future<color_model.Colors> setupColor({required String id}) async {
    final color = await _colorService.get(id: id);
    return color;
  }

  Future<Iterable<Notifications>> setupNotification({
    required String eventId,
  }) async {
    final notifications = await _notificationService.getByEventId(id: eventId);
    return notifications;
  }
}
