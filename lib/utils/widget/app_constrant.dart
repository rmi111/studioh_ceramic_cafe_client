import 'package:flutter/material.dart';

class AppDecorations {
  static BorderRadius get radius12 => BorderRadius.circular(12);
  static BorderRadius get radius24 => BorderRadius.circular(24);

  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}

class AppPadding {
  static EdgeInsets get all16 => const EdgeInsets.all(16);
  static EdgeInsets get horizontal20 =>
      const EdgeInsets.symmetric(horizontal: 20);
  static EdgeInsets get vertical10 => const EdgeInsets.symmetric(vertical: 10);
}

class SizeBoxUtils {
  static SizedBox height(double h) => SizedBox(height: h);
  static SizedBox width(double w) => SizedBox(width: w);

  static SizedBox space10 = const SizedBox(height: 10);
  static SizedBox space20 = const SizedBox(height: 20);
  static SizedBox spaceW10 = const SizedBox(width: 10);
}
