 import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(Object? value) {
    if (value == null) return '';

    DateTime? date;
    if (value is int) {
      date = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      date = DateTime.tryParse(value);
      // Some APIs may send millis as string
      date ??= int.tryParse(value) != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(value))
          : null;
    }

    if (date == null) return value.toString();
    return DateFormat('dd MMM yyyy, h:mm a').format(date);
  }
}

