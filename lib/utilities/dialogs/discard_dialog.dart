import 'package:flutter/material.dart';
import 'package:urtask/utilities/dialogs/generic_dialog.dart';

Future<bool> showDiscardDialog(BuildContext context, String content) {
  return showGenericDialog<bool>(
    context: context,
    content: content,
    optionsBuilder: () => {
      "Cancel": false,
      "Discard": true,
    },
  ).then((value) => value ?? false);
}
