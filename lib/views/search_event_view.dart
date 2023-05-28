import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/services/events/events_controller.dart';

class SearchEventView extends StatefulWidget {
  const SearchEventView({super.key});

  @override
  State<SearchEventView> createState() => _SearchEventViewState();
}

class _SearchEventViewState extends State<SearchEventView> {
  late final TextEditingController search;
  late final EventController _eventService;

  @override
  void initState() {
    search = TextEditingController();
    _eventService = EventController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
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
                      // Perform the search here
                      // You can call the _searchEvents method or trigger the search functionality
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Perform the search here
                // You can call the _searchEvents method or trigger the search functionality
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
      body: Column(),

      // FutureBuilder<List<Event>>(
      //   future: _eventService.search(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     } else if (snapshot.hasError) {
      //       return Center(
      //         child: Text('Error: ${snapshot.error}'),
      //       );
      //     } else {
      //       final events = snapshot.data ?? [];
      //       return ListView.builder(
      //         itemCount: events.length,
      //         itemBuilder: (context, index) {
      //           final event = events[index];
      //           return EventWidget(event: event);
      //         },
      //       );
      //     }
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        // Floating action button
        onPressed: () {
          // Perform the search here
          // You can call the _searchEvents method or trigger the search functionality
        },
        foregroundColor: Colors.white, // Set the icon color
        child: const Icon(Icons.search,
            size: 32, color: Colors.white), // Set the search icon
      ),
    );
  }
}

class Event {
  final String title;
  final String description;

  Event({required this.title, required this.description});

  factory Event.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final title = data['title'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    return Event(title: title, description: description);
  }
}

class EventWidget extends StatelessWidget {
  final Event event;

  const EventWidget({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text(event.description),
    );
  }
}
