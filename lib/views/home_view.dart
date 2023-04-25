import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:urtask/color.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:urtask/views/calendar_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _counter = 0;
  int _selectedDestination = 0;
  var uot = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //for
    final textTheme = theme.textTheme;
    var borderRadius = const BorderRadius.all(Radius.circular(20));
    final padding = 20;

    return Scaffold(
      appBar: AppBar(
        //leading: Icon(Icons.menu, size: 32, color: Colors.white),
        title: Text(DateFormat('yMMMM').format(DateTime.now()),
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.search, size: 32, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.event_available, size: 32, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.account_circle, size: 32, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: ListTile(
                title: Text('Week',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                selected: _selectedDestination == 1,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                onTap: () {
                  selectDestination(1);
                  uot = CalendarFormat.week;
                },
                contentPadding: const EdgeInsets.only(
                    top: 8.0, right: 8.0, bottom: 8.0, left: 12.0),
                selectedColor: Colors.white,
                selectedTileColor: primary,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8.0),
              child: ListTile(
                title: Text('Month',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                selected: _selectedDestination == 0,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                onTap: () {
                  selectDestination(0);
                  uot = CalendarFormat.month;
                },
                contentPadding: const EdgeInsets.only(
                  top: 8.0,
                  right: 8.0,
                  bottom: 8.0,
                  left: 12.0,
                ),
                selectedColor: Colors.white,
                selectedTileColor: primary,
              ),
            ),
            DottedLine(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Edit Category',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                selected: _selectedDestination == 3,
                onTap: () => selectDestination(3),
                contentPadding: const EdgeInsets.only(
                    top: 8.0, left: 12.0, right: 8.0, bottom: 8.0),
                selectedColor: Colors.white,
                selectedTileColor: primary,
              ),
            ),
            Divider(
              height: 1,
              thickness: 2,
            ),
            TaskList()
          ],
        ),
      ),
      body: calendar(calendarFilter: uot),
      floatingActionButton: SpeedDial(
        //Speed dial menu
        marginBottom: 10, //margin bottom
        icon: Icons.add_rounded, //icon on Floating action button
        activeIcon: Icons.close, //icon when menu is expanded on button
        backgroundColor: primary, //background color of button
        foregroundColor: Colors.white, //font color, icon color in button
        activeBackgroundColor: primary, //background color when menu is expanded
        activeForegroundColor: Colors.white,
        buttonSize: 56.0, //button size
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.white,
        overlayOpacity: 0.8,
        onOpen: () => print('OPENING DIAL'), // action when menu opens
        onClose: () => print('DIAL CLOSED'), //action when menu closes

        elevation: 8.0, //shadow elevation of button
        shape: CircleBorder(), //shape of button

        children: [
          SpeedDialChild(
            //speed dial child
            child: Icon(Icons.category),
            backgroundColor: secondary,
            foregroundColor: primary,
            label: 'Event Category',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('ADD EVENT CATEGORY'),
            onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.event),
            backgroundColor: secondary,
            foregroundColor: primary,
            label: 'Event',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('ADD EVENT'),
            onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
        ],
      ),
    );
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }
}

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TaskItem(label: "Birthdays"),
        TaskItem(label: "Consumables"),
        TaskItem(label: "Meeting"),
        TaskItem(label: "Public Holiday"),
        TaskItem(label: "Special Events"),
        TaskItem(label: "Subscriptions")
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final String label;
  const TaskItem({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Checkbox(value: false, onChanged: null), Text(label)],
    );
  }
}
