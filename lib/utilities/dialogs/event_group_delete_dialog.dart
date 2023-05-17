import 'package:flutter/material.dart';
import 'package:urtask/color.dart';

Future<bool> showEventGroupDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("This event has repetitions!",
            style: TextStyle(
              fontWeight: FontWeight.normal,
            )),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Only delete this event",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primary,
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
              ),
            ),
          )
        ],
      );
    },
  ).then((value) => value);
}
