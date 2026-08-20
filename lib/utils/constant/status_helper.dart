import 'package:flutter/material.dart';

class StatusHelper {
  static String getStatusLabel(String status) {
    switch (status) {
      case 'ready_for_glaze':
        return 'Ready for Glaze';
      case 'prepare_for_kiln':
        return 'Preparing for Kiln';
      case 'first_fire_kiln':
        return 'First Fire Kiln';
      case 'glaze_dipping_cleaning':
        return 'Glaze & Cleaning';
      case 'glaze_kiln':
        return 'Glaze Kiln';
      case 'sorting_for_collection':
        return 'Sorting for Collection';
      case 'ready_for_collection':
        return 'Ready for Collection';
      case 'collected':
        return 'Collected';
      case 'uncollected':
        return 'Uncollected';
      default:
        return status.replaceAll('_', ' ').split(' ').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'ready_for_glaze':
        return Colors.orange;
      case 'prepare_for_kiln':
        return Colors.amber;
      case 'first_fire_kiln':
        return Colors.deepOrange;
      case 'glaze_dipping_cleaning':
        return Colors.blue;
      case 'glaze_kiln':
        return Colors.indigo;
      case 'sorting_for_collection':
        return Colors.teal;
      case 'ready_for_collection':
        return Colors.green;
      case 'collected':
        return Colors.grey;
      case 'uncollected':
        return Colors.red;
      default:
        return Colors.brown;
    }
  }
}
