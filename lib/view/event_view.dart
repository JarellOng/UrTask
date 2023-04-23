import 'package:flutter/material.dart';
import 'package:urtask/service/events/events_controller.dart';
import 'package:urtask/service/events/events_model.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late final EventController _eventService;

  @override
  void initState() {
    _eventService = EventController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
      ),
      backgroundColor: const Color.fromARGB(31, 133, 133, 133),
      body: StreamBuilder(
        stream: _eventService.getAll(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final events = snapshot.data as Iterable<Events>;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events.elementAt(index);
                    return ListTile(
                      title: Text(
                        event.start.toDate().toIso8601String(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: Colors.amber,
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
      ),
    );
  }
}
