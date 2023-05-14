import 'package:flutter/material.dart';

import '../generated/l10n.dart';

void openSnackbar(context, message, color, duration) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      duration: Duration(seconds: duration),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}

showAlertDialog(context, title, message, continueFn) {
  final intl = S.of(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(intl.cancel),
          ),
          TextButton(
            onPressed: continueFn,
            child: Text(intl.continue_),
          ),
        ],
      );
    },
  );
}
