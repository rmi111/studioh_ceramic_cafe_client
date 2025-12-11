import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T) itemLabel;

  const AppDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(itemLabel(e)),
        );
      }).toList(),
    );
  }
}
