import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;

  const AppProgressBar({Key? key, required this.value, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: Colors.grey[300],
      color: color ?? Theme.of(context).primaryColor,
      minHeight: 8,
    );
  }
}
