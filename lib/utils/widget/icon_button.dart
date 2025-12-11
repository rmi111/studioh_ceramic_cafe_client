import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  const AppIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color ?? Colors.black),
      onPressed: onTap,
    );
  }
}
