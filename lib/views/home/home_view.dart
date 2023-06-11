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
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/services/user_details/user_detail_controller.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/views/auth/profile_view.dart';
import 'package:urtask/views/home/calendar_view.dart';
import 'package:urtask/views/category/categories_view.dart';
import 'package:urtask/views/event/create_event_view.dart';
import 'package:urtask/views/category/create_category_view.dart';
import 'package:urtask/views/home/search_event_view.dart';

List<String> myList = [];
Map<String, bool> checkboxListValues = {};

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

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
  late final EventController _eventService;
  late final CategoryController _categoryService;
  late final ColorController _colorService;

  @override
  void initState() {
    _eventService = EventController();
    _categoryService = CategoryController();
    _colorService = ColorController();
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 32, color: Colors.white),
              onPressed: () => _toSearchEvent(),
            ),
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
                onTap: () => _selectCalendarFormat(1, CalendarFormat.week),
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
            const Divider(
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: const Text(
                  'Edit Category',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                onTap: () => _toEventCategories(),
                contentPadding: const EdgeInsets.only(
                  top: 8.0,
                  left: 12.0,
                  right: 8.0,
                  bottom: 8.0,
                ),
                selectedColor: Colors.white,
                selectedTileColor: primary,
              ),
            ),
            const DottedLine(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450.0),
              child: const Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(10),
                thickness: 10,
                child: CategoryList(),
              ),
            )
          ],
        ),
      ),
      onDrawerChanged: (isOpened) => setState(() {
        today.text = "Update";
      }),
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

        elevation: 0, //shadow elevation of button
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
    showLoadingDialog(context: context, text: "Loading");
    Map<String, Map<Categories, color_model.Colors>> categories = {};
    final userDetail = await _userDetailService.get(id: user.id);
    final upcomingEvents = await _eventService.getUpcomingEvents();
    for (var element in upcomingEvents) {
      final category = await _categoryService.get(id: element.categoryId);
      final color = await _colorService.get(id: category.colorId);
      final categoryMap = {category: color};
      categories[element.id] = categoryMap;
    }
    final upcomingImportantEvents =
        await _eventService.getUpcomingImportantEvents();
    for (var element in upcomingImportantEvents) {
      final category = await _categoryService.get(id: element.categoryId);
      final color = await _colorService.get(id: category.colorId);
      final categoryMap = {category: color};
      categories[element.id] = categoryMap;
    }
    if (mounted) {
      Navigator.of(context).pop();
      final isLogout = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileView(
            name: userDetail.name,
            upcomingEvents: upcomingEvents.toList(),
            upcomingImportantEvents: upcomingImportantEvents.toList(),
            categories: categories,
          ),
        ),
      );
      setState(() {
        today.text = "Update";
      });
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
        builder: (context) => const CategoriesView(),
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

  void _toCreateEvent() async {
    final date = DateTime.parse(selectedDate.text);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventView(selectedDate: date),
      ),
    );
    setState(() {
      today.text = "Update";
    });
  }

  void _toSearchEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchEventView(),
      ),
    );
    setState(() {
      today.text = "Update";
    });
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late final CategoryController _categoryService;

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
                    onChanged: (newValue) => _toggleCategoryFilter(
                      category: category,
                      toggle: newValue,
                    ),
                    value: checkboxListValues[category.id] ?? true,
                    title: Text(
                      category.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w400),
                    ),
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

  void _toggleCategoryFilter({required Categories category, bool? toggle}) {
    setState(() {
      if (checkboxListValues[category.id] == null) {
        checkboxListValues[category.id] = true;
      }
      checkboxListValues[category.id] = !checkboxListValues[category.id]!;

      if (toggle == true) {
        myList.remove(category.id);
      }
      if (toggle == false) {
        myList.add(category.id);
      }
    });
  }
}
