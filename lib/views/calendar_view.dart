import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urtask/color.dart';
import 'package:intl/intl.dart';

class calendar extends StatefulWidget {
  final CalendarFormat calendarFilter;
  const calendar({
    super.key,
    required this.calendarFilter
    });

  @override
  State<calendar> createState() => _calendarState();
}

class _calendarState extends State<calendar>{ 
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20.0,),
            child: TableCalendar(focusedDay: focusedDay, 
                                 firstDay: DateTime.utc(2010, 10, 16), 
                                 lastDay: DateTime.utc(2025, 10, 16),
                                 rowHeight: 45,
                                 calendarFormat: widget.calendarFilter,
                                 headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
                                  formatButtonVisible: false,
                                  leftChevronVisible: false,
                                  rightChevronVisible: false
                                 ),
                                 //headerVisible: false,
                                 onDaySelected: (DateTime selectDay, DateTime focusDay) {
                                  setState(() {
                                    selectedDay = selectDay;  
                                    focusedDay = focusDay;
                                  });
                                  print(focusedDay);
                                },
                                selectedDayPredicate: (DateTime date) {
                                  return isSameDay(selectedDay, date);
                                },
                                calendarStyle: CalendarStyle(
                                  weekendTextStyle: TextStyle(color: Colors.red),
      
                                  selectedDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tertiary,
                                  ),
                                ),),
          ),
          Divider(
              height: 2,
              thickness: 2,
              color: Colors.black26,
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 16.0, left: 16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: 
                Text(DateFormat('yMMMMd').format(selectedDay), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))
              ),
          ),
          ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0, right: 12.0),
                child: ListTile(
                  leading: Transform.translate(
                    offset: Offset(-8, -6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Column(
                    children: [Text("17.00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), Text("19.00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black45))]
                  ),
                        ),
                  VerticalDivider(color: Colors.black45),
                      ],
                    )),
                  title: Text("Vincent's Birthday", style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Align(
                    alignment: Alignment.topLeft,
                    child: Chip(
                          backgroundColor: Colors.orange,
                          label: const Text('Birthday', style: TextStyle(color: Colors.white)),
                        ),
                   ),
                  horizontalTitleGap: -2,   
                  trailing: Icon(Icons.error_outlined, size: 32, color: Colors.red),
                  shape: Border(
                    bottom: BorderSide(color: Colors.black26)
                ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0, right: 12.0),
                child: ListTile(
                  leading: Transform.translate(
                    offset: Offset(-8, -6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Column(
                    children: [Text("All", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), Text("Day", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black45))]
                  ),
                        ),
                  VerticalDivider(color: Colors.black45),
                      ],
                    )),
                  title: Text("James Kumala's Favorite day", style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Align(
                    alignment: Alignment.topLeft,
                    child: Chip(
                          backgroundColor: Colors.purple,
                          label: const Text('Special Events', style: TextStyle(color: Colors.white)),
                        ),
                   ),
                  horizontalTitleGap: -2,
                  shape: Border(
                    bottom: BorderSide(color: Colors.black26)
                ),
                ),
              ),
            ],
           
          )
        ],
      );
}
}