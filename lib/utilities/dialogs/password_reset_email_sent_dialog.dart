import 'package:flutter/material.dart';
import 'package:urtask/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    content:
        "We have now sent you a password reset. Please check your email for more information.",
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
