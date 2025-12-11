import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AppSnackbar {
  static Color? get background => null;

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.done,color: Colors.white,),SizedBox(width: 5,),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
   static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded,color: Colors.white,),SizedBox(width: 5,),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
