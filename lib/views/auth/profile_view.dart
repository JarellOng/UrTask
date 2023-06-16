import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';
import 'package:urtask/services/user_details/user_detail_controller.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/dialogs/logout_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/event/event_detail_view.dart';

class ProfileView extends StatefulWidget {
  final String name;
  final List<Events> upcomingEvents;
  final List<Events> upcomingImportantEvents;
  final Map<String, Map<Categories, color_model.Colors>> categories;

  const ProfileView({
    Key? key,
    required this.name,
    required this.upcomingEvents,
    required this.upcomingImportantEvents,
    required this.categories,
  }) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final NotificationController _notificationService;
  late final UserDetailController _userDetailService;
  final user = AuthService.firebase().currentUser!;
  late final TextEditingController name;
  late final FocusNode nameFocus;
  bool nameFlag = true;

  @override
  void initState() {
    _notificationService = NotificationController();
    _userDetailService = UserDetailController();
    name = TextEditingController(text: widget.name);
    nameFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
    nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME
              const Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      focusNode: nameFocus,
                      readOnly: nameFlag,
                      controller: name,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: "Name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (nameFlag == true) ...[
                    TextButton(
                      onPressed: () => _changeName(),
                      child: const Text(
                        "Change",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => _saveName(),
                      child: const Text(
                        "Save",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ],
              ),

              // EMAIL
              const SizedBox(height: 16.0),
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                user.email,
                style: const TextStyle(fontSize: 18),
              ),

              // UPCOMING EVENTS
              const SizedBox(height: 28.0),
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5.0),
              if (widget.upcomingEvents.isEmpty) ...[
                const Text(
                  "There are no events..",
                  style: TextStyle(fontSize: 18),
                ),
              ] else ...[
                const Divider(
                  thickness: 1,
                  color: Colors.black26,
                ),
                if (widget.upcomingEvents.isNotEmpty) ...[
                  ListTile(
                    minVerticalPadding: 0,
                    onTap: () => _setupEventDetailDataAndPush(
                      event: widget.upcomingEvents[0],
                      category: widget
                          .categories[widget.upcomingEvents[0].id]!.keys.first,
                      color: widget.categories[widget.upcomingEvents[0].id]!
                          .values.first,
                    ),
                    title: Text(
                      widget.upcomingEvents[0].title.length > 34
                          ? "${widget.upcomingEvents[0].title.substring(0, 37)}.."
                          : widget.upcomingEvents[0].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Chip(
                                backgroundColor: HexColor.fromHex(widget
                                    .categories[widget.upcomingEvents[0].id]!
                                    .values
                                    .first
                                    .hex),
                                label: Text(
                                  widget
                                      .categories[widget.upcomingEvents[0].id]!
                                      .keys
                                      .first
                                      .name
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${DateTimeHelper.dateToString(
                                  month: widget.upcomingEvents[0].start
                                          .toDate()
                                          .month -
                                      1,
                                  day: widget.upcomingEvents[0].start
                                          .toDate()
                                          .day -
                                      1,
                                  year: widget.upcomingEvents[0].start
                                      .toDate()
                                      .year,
                                )} at ${DateTimeHelper.timeToString(
                                  hour: widget.upcomingEvents[0].start
                                      .toDate()
                                      .hour,
                                  minute: widget.upcomingEvents[0].start
                                      .toDate()
                                      .minute,
                                )}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.upcomingEvents.length >= 2) ...[
                  const Divider(
                    thickness: 1,
                    color: Colors.black26,
                  ),
                  ListTile(
                    minVerticalPadding: 0,
                    onTap: () => _setupEventDetailDataAndPush(
                      event: widget.upcomingEvents[1],
                      category: widget
                          .categories[widget.upcomingEvents[1].id]!.keys.first,
                      color: widget.categories[widget.upcomingEvents[1].id]!
                          .values.first,
                    ),
                    title: Text(
                      widget.upcomingEvents[1].title.length > 34
                          ? "${widget.upcomingEvents[1].title.substring(0, 37)}.."
                          : widget.upcomingEvents[1].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Chip(
                                backgroundColor: HexColor.fromHex(widget
                                    .categories[widget.upcomingEvents[1].id]!
                                    .values
                                    .first
                                    .hex),
                                label: Text(
                                  widget
                                      .categories[widget.upcomingEvents[1].id]!
                                      .keys
                                      .first
                                      .name
                                      .toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${DateTimeHelper.dateToString(
                                  month: widget.upcomingEvents[1].start
                                          .toDate()
                                          .month -
                                      1,
                                  day: widget.upcomingEvents[1].start
                                          .toDate()
                                          .day -
                                      1,
                                  year: widget.upcomingEvents[1].start
                                      .toDate()
                                      .year,
                                )} at ${DateTimeHelper.timeToString(
                                  hour: widget.upcomingEvents[1].start
                                      .toDate()
                                      .hour,
                                  minute: widget.upcomingEvents[1].start
                                      .toDate()
                                      .minute,
                                )}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.upcomingEvents.length >= 3) ...[
                  const Divider(
                    thickness: 1,
                    color: Colors.black26,
                  ),
                  ListTile(
                    minVerticalPadding: 0,
                    onTap: () => _setupEventDetailDataAndPush(
                      event: widget.upcomingEvents[2],
                      category: widget
                          .categories[widget.upcomingEvents[2].id]!.keys.first,
                      color: widget.categories[widget.upcomingEvents[2].id]!
                          .values.first,
                    ),
                    title: Text(
                      widget.upcomingEvents[2].title.length > 34
                          ? "${widget.upcomingEvents[2].title.substring(0, 37)}.."
                          : widget.upcomingEvents[2].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Chip(
                                backgroundColor: HexColor.fromHex(widget
                                    .categories[widget.upcomingEvents[2].id]!
                                    .values
                                    .first
                                    .hex),
                                label: Text(
                                  widget
                                      .categories[widget.upcomingEvents[2].id]!
                                      .keys
                                      .first
                                      .name
                                      .toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${DateTimeHelper.dateToString(
                                  month: widget.upcomingEvents[2].start
                                          .toDate()
                                          .month -
                                      1,
                                  day: widget.upcomingEvents[2].start
                                          .toDate()
                                          .day -
                                      1,
                                  year: widget.upcomingEvents[2].start
                                      .toDate()
                                      .year,
                                )} at ${DateTimeHelper.timeToString(
                                  hour: widget.upcomingEvents[2].start
                                      .toDate()
                                      .hour,
                                  minute: widget.upcomingEvents[2].start
                                      .toDate()
                                      .minute,
                                )}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Divider(
                  thickness: 1,
                  color: Colors.black26,
                ),
              ],

              // UPCOMING IMPORTANT EVENTS
              const SizedBox(height: 28.0),
              const Text(
                'Upcoming Important Events',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5.0),
              if (widget.upcomingImportantEvents.isEmpty) ...[
                const Text(
                  "There are no important events..",
                  style: TextStyle(fontSize: 18),
                ),
              ] else ...[
                const Divider(
                  thickness: 1,
                  color: Colors.black26,
                ),
                if (widget.upcomingImportantEvents.isNotEmpty) ...[
                  ListTile(
                    minVerticalPadding: 0,
                    onTap: () => _setupEventDetailDataAndPush(
                      event: widget.upcomingImportantEvents[0],
                      category: widget
                          .categories[widget.upcomingImportantEvents[0].id]!
                          .keys
                          .first,
                      color: widget
                          .categories[widget.upcomingImportantEvents[0].id]!
                          .values
                          .first,
                    ),
                    title: Text(
                      widget.upcomingImportantEvents[0].title.length > 34
                          ? "${widget.upcomingImportantEvents[0].title.substring(0, 37)}.."
                          : widget.upcomingImportantEvents[0].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Chip(
                                backgroundColor: HexColor.fromHex(widget
                                    .categories[
                                        widget.upcomingImportantEvents[0].id]!
                                    .values
                                    .first
                                    .hex),
                                label: Text(
                                  widget
                                      .categories[
                                          widget.upcomingImportantEvents[0].id]!
                                      .keys
                                      .first
                                      .name
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${DateTimeHelper.dateToString(
                                  month: widget.upcomingImportantEvents[0].start
                                          .toDate()
                                          .month -
                                      1,
                                  day: widget.upcomingImportantEvents[0].start
                                          .toDate()
                                          .day -
                                      1,
                                  year: widget.upcomingImportantEvents[0].start
                                      .toDate()
                                      .year,
                                )} at ${DateTimeHelper.timeToString(
                                  hour: widget.upcomingImportantEvents[0].start
                                      .toDate()
                                      .hour,
                                  minute: widget
                                      .upcomingImportantEvents[0].start
                                      .toDate()
                                      .minute,
                                )}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.upcomingImportantEvents.length >= 2) ...[
                  const Divider(
                    thickness: 1,
                    color: Colors.black26,
                  ),
                  ListTile(
                    minVerticalPadding: 0,
                    onTap: () => _setupEventDetailDataAndPush(
                      event: widget.upcomingImportantEvents[1],
                      category: widget
                          .categories[widget.upcomingImportantEvents[1].id]!
                          .keys
                          .first,
                      color: widget
                          .categories[widget.upcomingImportantEvents[1].id]!
                          .values
                          .first,
                    ),
                    title: Text(
                      widget.upcomingImportantEvents[1].title.length > 34
                          ? "${widget.upcomingImportantEvents[1].title.substring(0, 37)}.."
                          : widget.upcomingImportantEvents[1].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Chip(
                                backgroundColor: HexColor.fromHex(widget
                                    .categories[
                                        widget.upcomingImportantEvents[1].id]!
                                    .values
                                    .first
                                    .hex),
                                label: Text(
                                  widget
                                      .categories[
                                          widget.upcomingImportantEvents[1].id]!
                                      .keys
                                      .first
                                      .name
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${DateTimeHelper.dateToString(
                                  month: widget.upcomingImportantEvents[1].start
                                          .toDate()
                                          .month -
                                      1,
                                  day: widget.upcomingImportantEvents[1].start
                                          .toDate()
                                          .day -
                                      1,
                                  year: widget.upcomingImportantEvents[1].start
                                      .toDate()
                                      .year,
                                )} at ${DateTimeHelper.timeToString(
                                  hour: widget.upcomingImportantEvents[1].start
                                      .toDate()
                                      .hour,
                                  minute: widget
                                      .upcomingImportantEvents[1].start
                                      .toDate()
                                      .minute,
                                )}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.upcomingImportantEvents.length >= 3) ...[
                  const Divider(
                    thickness: 1,
                    color: Colors.black26,
                  ),
                  ListTile(
                    minVerticalPadding: 0,
                    onTap: () => _setupEventDetailDataAndPush(
                      event: widget.upcomingImportantEvents[2],
                      category: widget
                          .categories[widget.upcomingImportantEvents[2].id]!
                          .keys
                          .first,
                      color: widget
                          .categories[widget.upcomingImportantEvents[2].id]!
                          .values
                          .first,
                    ),
                    title: Text(
                      widget.upcomingImportantEvents[2].title.length > 34
                          ? "${widget.upcomingImportantEvents[2].title.substring(0, 37)}.."
                          : widget.upcomingImportantEvents[2].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Chip(
                                backgroundColor: HexColor.fromHex(widget
                                    .categories[
                                        widget.upcomingImportantEvents[2].id]!
                                    .values
                                    .first
                                    .hex),
                                label: Text(
                                  widget
                                      .categories[
                                          widget.upcomingImportantEvents[2].id]!
                                      .keys
                                      .first
                                      .name
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${DateTimeHelper.dateToString(
                                  month: widget.upcomingImportantEvents[2].start
                                          .toDate()
                                          .month -
                                      1,
                                  day: widget.upcomingImportantEvents[2].start
                                          .toDate()
                                          .day -
                                      1,
                                  year: widget.upcomingImportantEvents[2].start
                                      .toDate()
                                      .year,
                                )} at ${DateTimeHelper.timeToString(
                                  hour: widget.upcomingImportantEvents[2].start
                                      .toDate()
                                      .hour,
                                  minute: widget
                                      .upcomingImportantEvents[2].start
                                      .toDate()
                                      .minute,
                                )}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Divider(
                  thickness: 1,
                  color: Colors.black26,
                ),
              ],

              // LOGOUT
              const SizedBox(height: 28.0),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: TextButton(
                    onPressed: () => _shouldLogout(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF9C3B35)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setupEventDetailDataAndPush({
    required Events event,
    required Categories category,
    required color_model.Colors color,
  }) async {
    showLoadingDialog(context: context, text: "Loading");
    final notifications = await _notificationService.getByEventId(id: event.id);
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
            categoryName: category.name,
            categoryHex: color.hex,
            notifications: notifications,
          ),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _changeName() {
    setState(() {
      nameFlag = false;
      nameFocus.requestFocus();
    });
  }

  void _saveName() async {
    setState(() {
      nameFocus.unfocus();
      nameFlag = true;
    });
    await _userDetailService.updateName(id: user.id, name: name.text);
  }

  void _shouldLogout() async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      if (mounted) {
        Navigator.of(context).pop(shouldLogout);
      }
    }
  }
}
