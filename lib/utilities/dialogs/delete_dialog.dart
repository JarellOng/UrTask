import 'package:flutter/material.dart';
import 'package:urtask/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context, String content) {
  return showGenericDialog<bool>(
    context: context,
    content: content,
    optionsBuilder: () => {
      "Cancel": false,
      "Delete": true,
    },
  ).then((value) => value ?? false);
}
