import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:urtask/color.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/utilities/dialogs/categories_dialog.dart';
import 'package:urtask/views/calendar_view.dart';
import 'package:urtask/views/profile_view.dart';
import 'package:urtask/views/categories_view.dart';
import 'package:urtask/views/event/create_event_view.dart';
import 'package:urtask/views/create_category_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _counter = 0;
  int _selectedDestination = 0;
  var uot = CalendarFormat.month;
  late final TextEditingController today;
  late final CalendarController _calendarService;

  @override
  void initState() {
    today = TextEditingController();
    _calendarService = CalendarController();
    _setupCalendar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //for
    final textTheme = theme.textTheme;
    var borderRadius = const BorderRadius.all(Radius.circular(20));
    final padding = 20;
    final userId = AuthService.firebase().currentUser!.id;

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

          // Show Today
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(
                Icons.event_available,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  today.text = "Today";
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.account_circle,
                  size: 32, color: Colors.white),
              onPressed: () async {
                final isLogout = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
                if (isLogout == true) {
                  if (mounted) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                }
              },
            ),
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryView(),
                  ),
                ),
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
            CategoryList()
          ],
        ),
      ),
      body: CalendarView(calendarFilter: uot, today: today),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCategoryView(),
              ),
            ),
            onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.event),
            backgroundColor: secondary,
            foregroundColor: primary,
            label: 'Event',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEventView(),
              ),
            ),
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

  void _setupCalendar() async {
    final calendar = await _calendarService.get();
    if (calendar == null) {
      await _calendarService.create(userId: userId);
    }
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  bool? _value = true;
  late final CategoryController _categoryService;
  //List<bool> checkboxValues = [];
  //int i = 0;

  @override
  void initState() {
    _categoryService = CategoryController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _categoryService.getAll(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (snapshot.hasData) {
              final categories = snapshot.data as Iterable<Categories>;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories.elementAt(index);
                  return CheckboxListTile(
                    onChanged: (newValue) => setState(() {
                      _value = newValue;
                    }),
                    value: _value,
                    title: Text(category.name),
                    controlAffinity: ListTileControlAffinity.leading,
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
}
