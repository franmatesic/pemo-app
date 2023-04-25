import 'package:flutter/material.dart';

void openSnackbar(context, message, color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: "OK", textColor: Colors.white, onPressed: () {}),
      content: Text(message, style: const TextStyle(fontSize: 16))));
}
