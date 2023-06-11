import 'package:flutter/material.dart';
import 'package:urtask/utilities/dialogs/generic_dialog.dart';

Future<void> showSuccessDialog(BuildContext context, String content) {
  return showGenericDialog(
    context: context,
    content: content,
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
