import 'package:flutter/material.dart';
import 'package:urtask/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    content: "Are you sure you want to log out?",
    optionsBuilder: () => {
      "No": false,
      "Yes": true,
    },
  ).then((value) => value ?? false);
}
