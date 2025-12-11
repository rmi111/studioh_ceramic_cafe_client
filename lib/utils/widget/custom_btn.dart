import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final Color? bgcolor;
  final Color? textColor;
  final double? fontSize;
  final IconData? iconData;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.bgcolor,
    this.textColor,
    this.fontSize,
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      minimumSize: Size(150, 45),
maximumSize: Size(double.infinity, 45)
    ),
    onPressed: onPressed,
    child: CustomText(
      text: text,
      color: Colors.white,
    ),
    );
  }
}
