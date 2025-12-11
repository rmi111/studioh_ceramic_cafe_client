import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_text.dart';



class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final void Function(T?) onChanged;
  final String label;

  const AppRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        CustomText(text: label),
      ],
    );
  }
}
