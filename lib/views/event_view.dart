import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';

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

  @override
  void initState() {
    _eventService = EventController();
    _categoryController = CategoryController();
    _colorService = ColorController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _eventService.getByDay(dateTime: widget.selectedDay),
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
              return const CircularProgressIndicator();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
