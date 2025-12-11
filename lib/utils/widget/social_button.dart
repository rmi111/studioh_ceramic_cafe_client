
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed:onTap,
      icon: Icon(icon, size: 28,),
      label: Text(
        label,
        style: TextStyle(fontSize: 18,color: Colors.black),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 40),
        side: BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
