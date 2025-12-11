import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextInputType? textInputType;
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isPassword;
  final FocusNode? focusNode;
  final int maxLines;
  final String? prefixText;
  final bool isEnabled;
  const AppTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.icon,
    this.isEnabled = true,
    this.maxLines = 1,
    this.isPassword = false,
    this.focusNode,
    this.prefixText,
    this.textInputType = TextInputType.text,
    required TextInputType keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Center(
            child: TextField(
              keyboardType: textInputType,
              maxLines: maxLines,
              controller: controller,

              decoration: InputDecoration(
                prefixText: prefixText,
                enabled: isEnabled,
                prefixIcon: icon != null ? Icon(icon) : null,
                hintText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
              ),
            ),
          ),
        ),

    );
  }
}
