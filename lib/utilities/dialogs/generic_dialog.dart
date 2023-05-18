import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          content: Text(
            content,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.keys.map((optionTitle) {
                final T value = options[optionTitle];
                return TextButton(
                  onPressed: () {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    optionTitle,
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              }).toList(),
            )
          ]);
    },
  );
}
