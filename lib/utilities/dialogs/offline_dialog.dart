import 'package:flutter/material.dart';

void showOfflineDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  showDialog(
    context: context,
    builder: (context) => dialog,
  );
}
