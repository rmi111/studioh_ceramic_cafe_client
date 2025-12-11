 import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(int millis) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('dd MMM yyyy, h:mm a').format(date);
  }
}

