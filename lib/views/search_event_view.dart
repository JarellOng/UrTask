import 'package:flutter/material.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/services/notifications/notifications_model.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/event/event_detail_view.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;

class SearchEventView extends StatefulWidget {
  const SearchEventView({super.key});

  @override
  State<SearchEventView> createState() => _SearchEventViewState();
}

class _SearchEventViewState extends State<SearchEventView> {
  late final TextEditingController search;
  late final EventController _eventService;
  late final CategoryController _categoryController;
  late final ColorController _colorService;
  late final NotificationController _notificationService;
  String? searchQuery;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    search = TextEditingController();
    _eventService = EventController();
    _categoryController = CategoryController();
    _colorService = ColorController();
    _notificationService = NotificationController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Curved edges
                ),
                child: Center(
                  child: TextField(
                    controller: search,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Enter Event Title',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center, // Center the label
                    onChanged: (value) {
                      // Update the search term here
                      // You can set the searchTerm variable or use a state management solution
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchQuery = search.text;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  searchQuery = search.text;
                });
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: searchQuery == null
          ? Column()
          : StreamBuilder(
              stream: _eventService.search(query: searchQuery!),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final events = snapshot.data as Iterable<Events>;
                      if (events.isEmpty) {
                        return Column(
                          children: const [
                            SizedBox(height: 20),
                            Center(
                              child: Text(
                                "No events found...",
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        );
                      }
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
                                onTap: () =>
                                    _setupEventDetailDataAndPush(event: event),
                                leading: Transform.translate(
                                  offset: const Offset(-8, -6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 125,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
                                          child: Column(children: [
                                            Text(
                                              DateTimeHelper.dateToString(
                                                month: startDate.month - 1,
                                                day: startDate.day - 1,
                                                year: startDate.year,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            Text(
                                              DateTimeHelper.timeToString(
                                                hour: startDate.hour,
                                                minute: startDate.minute,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                      const VerticalDivider(
                                          color: Colors.black45),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  event.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Align(
                                  alignment: Alignment.topLeft,
                                  child: FutureBuilder(
                                    future: _categoryController.get(
                                        id: event.categoryId),
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
                                                  switch (snapshot
                                                      .connectionState) {
                                                    case ConnectionState.done:
                                                      if (snapshot.hasData) {
                                                        final color =
                                                            snapshot.data
                                                                as color_model
                                                                    .Colors;
                                                        return Chip(
                                                          backgroundColor:
                                                              HexColor.fromHex(
                                                                  color.hex),
                                                          label: Text(
                                                            category.name,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
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
            ),
    );
  }

  void _setupEventDetailDataAndPush({required Events event}) async {
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
}
