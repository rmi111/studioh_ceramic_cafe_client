import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? align;
final double? fontSizeFactor; 
  const CustomText({
    Key? key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.align, this.fontSizeFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseFontSize = MediaQuery.of(context).size.width * 0.04; // base size
    double finalFontSize = fontSizeFactor != null ? baseFontSize * fontSizeFactor! : baseFontSize;

    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: finalFontSize,
        fontFamily: 'Poppins',
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? Colors.black,
      ),
    );
  }
}
