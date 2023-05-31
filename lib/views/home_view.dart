import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:urtask/color.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/auth/auth_user.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/user_details/user_detail_controller.dart';
import 'package:urtask/views/calendar_view.dart';
import 'package:urtask/views/profile_view.dart';
import 'package:urtask/views/category/categories_view.dart';
import 'package:urtask/views/event/create_event_view.dart';
import 'package:urtask/views/category/create_category_view.dart';

List<String> myList = [];
Map<String, bool> checkboxListValues = {};

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedDestination = 0;
  var uot = CalendarFormat.month;
  late final TextEditingController today;
  late final CalendarController _calendarService;
  late final UserDetailController _userDetailService;
  late final TextEditingController selectedDate;
  final currentUser = AuthService.firebase().currentUser!;

  @override
  void initState() {
    today = TextEditingController();
    _calendarService = CalendarController();
    _userDetailService = UserDetailController();
    selectedDate = TextEditingController(text: DateTime.now().toString());
    _setupCalendar();
    super.initState();
  }

  @override
  void dispose() {
    today.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = const BorderRadius.all(Radius.circular(20));

    return Scaffold(
      appBar: AppBar(
        //leading: Icon(Icons.menu, size: 32, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.search, size: 32, color: Colors.white),
          ),

          // Show Today
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: const Icon(
                Icons.event_available,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () => _toToday(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () => _toProfile(user: currentUser),
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
                title: const Text(
                  'Week',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                selected: _selectedDestination == 1,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                onTap: () {
                  _selectCalendarFormat(1, CalendarFormat.week);
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
            Padding(
              padding:
                  const EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8.0),
              child: ListTile(
                title: const Text(
                  'Month',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                selected: _selectedDestination == 0,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                onTap: () => _selectCalendarFormat(0, CalendarFormat.month),
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
            const DottedLine(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  'Edit Category',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                onTap: () => _toEventCategories(),
                contentPadding: const EdgeInsets.only(
                    top: 8.0, left: 12.0, right: 8.0, bottom: 8.0),
                selectedColor: Colors.white,
                selectedTileColor: primary,
              ),
            ),
            const Divider(
              height: 1,
              thickness: 2,
            ),
            ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 465.0,
                ),
                child: const CategoryList())
          ],
        ),
      ),
      body: CalendarView(
        myList: myList,
        calendarFilter: uot,
        today: today,
        selectedDate: selectedDate,
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
        //action when menu closes

        elevation: 8.0, //shadow elevation of button
        shape: const CircleBorder(), //shape of button

        children: [
          SpeedDialChild(
            //speed dial child
            child: const Icon(Icons.category),
            backgroundColor: secondary,
            foregroundColor: primary,
            label: 'Event Category',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () => _toCreateCategory(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.event),
            backgroundColor: secondary,
            foregroundColor: primary,
            label: 'Event',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () => _toCreateEvent(),
          ),
        ],
      ),
    );
  }

  void _selectCalendarFormat(int index, CalendarFormat format) {
    setState(() {
      _selectedDestination = index;
      uot = format;
    });
  }

  void _setupCalendar() async {
    final calendar = await _calendarService.get();
    if (calendar == null) {
      await _calendarService.create(userId: currentUser.id);
    }
  }

  void _toToday() {
    setState(() {
      today.text = "Today";
    });
  }

  void _toProfile({required AuthUser user}) async {
    final userDetail = await _userDetailService.get(id: user.id);
    if (mounted) {
      final isLogout = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileView(name: userDetail.name),
        ),
      );
      if (isLogout == true) _logout();
    }
  }

  void _logout() async {
    context.read<AuthBloc>().add(const AuthEventLogOut());
  }

  void _toEventCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryView(),
      ),
    );
  }

  void _toCreateCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCategoryView(),
      ),
    );
  }

  void _toCreateEvent() {
    final date = DateTime.parse(selectedDate.text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventView(selectedDate: date),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
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
              categories.map((e) => checkboxListValues[e.id] = true);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories.elementAt(index);
                  return CheckboxListTile(
                    onChanged: (newValue) => setState(() {
                      if (checkboxListValues[category.id] == null) {
                        checkboxListValues[category.id] = true;
                      }
                      checkboxListValues[category.id] =
                          !checkboxListValues[category.id]!;
                      //print(checkboxListValues);

                      if (newValue == true) {
                        myList.remove(category.id);
                      }
                      if (newValue == false) {
                        myList.add(category.id);
                      }

                      print(myList);
                    }),
                    value: checkboxListValues[category.id] ?? true,
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
