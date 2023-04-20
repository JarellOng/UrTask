import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:urtask/color.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _counter = 0;
  int _selectedDestination = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //for
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        //leading: Icon(Icons.menu, size: 32, color: Colors.white),
        title: Text("June 2023"),
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
          // Important: Remove any padding from the ListView.
          //padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Week'),
              selected: _selectedDestination == 0,
              onTap: () => selectDestination(0),
              selectedColor: Colors.white,
              selectedTileColor: primary,
            ),
            ListTile(
              title: Text('Month'),
              selected: _selectedDestination == 1,
              onTap: () => selectDestination(1),
              selectedColor: Colors.white,
              selectedTileColor: primary,
            ),
            DottedLine(),
            ListTile(
              title: Text('Edit Category'),
              selected: _selectedDestination == 3,
              onTap: () => selectDestination(3),
              selectedColor: Colors.white,
              selectedTileColor: primary,
            ),
            Divider(
              height: 1,
              thickness: 2,
            ),
            TaskList()
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: textTheme.headline4,
            ),
            Progress(),
          ],
        ),
      ),
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

class Progress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("testing"),
      ],
    );
  }
}
