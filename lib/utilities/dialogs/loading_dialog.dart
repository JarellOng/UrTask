import 'package:flutter/material.dart';

void showLoadingDialog({
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
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    ),
  );

  showDialog(
    context: context,
    builder: (context) => dialog,
    barrierDismissible: false,
  );
}
