import 'package:flutter/material.dart';
import 'package:urtask/color.dart';

Future<bool> showEventGroupDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: const Text("This event has repetitions!",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
            )),
        children: [
          const SizedBox(height: 10),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Only delete this event",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primary,
                fontSize: 18,
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Delete all repeated events",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primary,
                fontSize: 18,
              ),
            ),
          )
        ],
      );
    },
  ).then((value) => value);
}
