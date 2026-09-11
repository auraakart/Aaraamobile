import 'package:flutter/material.dart';

void myAppSnackError(String message, BuildContext ctx) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    ),
  );
}

void myAppSnackSuccess(String message, BuildContext ctx) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    ),
  );
}


