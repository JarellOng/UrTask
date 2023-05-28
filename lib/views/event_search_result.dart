import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventSearchResults extends StatelessWidget {
  final String searchTerm;
  final TextEditingController _searchController = TextEditingController();

  EventSearchResults({Key? key, required this.searchTerm}) : super(key: key);

  Future<List<Event>> _searchEvents() async {
    final events = FirebaseFirestore.instance.collection('events');
    final querySnapshot = await events.get();
    if (searchTerm.isEmpty) {
      return querySnapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    } else {
      return querySnapshot.docs
          .map((doc) => Event.fromSnapshot(doc))
          .where((event) =>
              event.title.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    _searchController.text = searchTerm;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 30,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Curved edges
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    decoration: InputDecoration(
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
            SizedBox(width: 8),
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
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Event>>(
        future: _searchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final events = snapshot.data ?? [];
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventWidget(event: event);
              },
            );
          }
        },
      ),
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
