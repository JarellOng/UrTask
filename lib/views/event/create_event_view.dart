import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/utilities/dialogs/categories_dialog.dart';
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
  late final TextEditingController _eventTitle;
  late final TextEditingController _eventDescription;
  late final FixedExtentScrollController _eventStartDay;
  late final FixedExtentScrollController _eventStartMonth;
  late final FixedExtentScrollController _eventStartYear;
  late final FixedExtentScrollController _eventStartHour;
  late final FixedExtentScrollController _eventStartMinute;
  late final CategoryController _categoryService;
  late final ColorController _colorService;
  int dayTest = 0;
  bool allDay = false;
  bool important = false;
  String category = "Meeting";
  String categoryHex = "#039be5";

  @override
  void initState() {
    _eventService = EventController();
    _eventTitle = TextEditingController();
    _eventDescription = TextEditingController();
    _eventStartDay = FixedExtentScrollController(
      initialItem: DateTime.now().day - 1,
    );
    _eventStartMonth = FixedExtentScrollController(
      initialItem: DateTime.now().month - 1,
    );
    _eventStartYear = FixedExtentScrollController();
    _eventStartHour = FixedExtentScrollController(
      initialItem: DateTime.now().hour + 1,
    );
    _eventStartMinute = FixedExtentScrollController();
    _categoryService = CategoryController();
    _colorService = ColorController();
    super.initState();
  }

  @override
  void dispose() {
    _eventTitle.dispose();
    _eventDescription.dispose();
    _eventStartDay.dispose();
    _eventStartMonth.dispose();
    _eventStartYear.dispose();
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
      ),
      body: Column(
        children: [
          // Title
          TextField(
            controller: _eventTitle,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Title",
            ),
          ),

          // All Day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("All Day"),
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: allDay,
                  onChanged: (value) {
                    setState(() {
                      allDay = value;
                    });
                  },
                  // activeTrackColor: primary,
                  activeColor: primary,
                ),
              ),
            ],
          ),

          // Start
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Start"),
            ],
          ),

          // End
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("End"),
            ],
          ),

          // Date Scroll
          // DateScrollView(
          //   day: _eventStartDay,
          //   month: _eventStartMonth,
          //   year: _eventStartYear,
          // ),

          // Time Scroll
          // TimeScrollView(
          //   hour: _eventStartHour,
          //   minute: _eventStartMinute,
          // ),

          // Important
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Important"),
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: important,
                  onChanged: (value) {
                    setState(() {
                      important = value;
                    });
                  },
                  // activeTrackColor: primary,
                  activeColor: primary,
                ),
              ),
            ],
          ),

          // Category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Category"),
              TextButton(
                onPressed: () async {
                  final categoryDetail = await showCategoriesDialog(
                    context,
                    _categoryService,
                    _colorService,
                  );
                  if (categoryDetail.isNotEmpty) {
                    setState(() {
                      category = categoryDetail[1];
                      categoryHex = categoryDetail[2];
                    });
                  }
                },
                child: Chip(
                  backgroundColor: HexColor.fromHex(categoryHex),
                  label: Text(
                    category,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          // Repeat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Repeat"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RepeatEventView(),
                    ),
                  );
                },
                child: const Text("Repeat"),
              ),
            ],
          ),

          // Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Notification"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationEventView(),
                    ),
                  );
                },
                child: const Text("Notification"),
              ),
            ],
          ),

          // Description
          TextField(
            controller: _eventDescription,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Description",
            ),
          ),

          // Login Button
          TextButton(
            onPressed: () async {
              final startDay = _eventStartDay.selectedItem;
              // final startHour = _eventStartHour.selectedItem;
              // final startMinute = _eventStartMinute.selectedItem;
              print(startDay);
              // print(startMinute);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
