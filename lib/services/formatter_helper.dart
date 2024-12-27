import 'package:flutter/material.dart';

class FormatterHelper {
  static String toFixed2(String value,
      {String prefix = "RM", negative = false}) {
    // Remove all non-numeric characters
    try {
     String newValue = value.replaceAll(RegExp(r'(?<!^)-|[^0-9-]'), "");
      

      // Ensure at least two digits for the decimal conversion
      negative = double.parse(newValue) < 0 || negative;
      newValue = newValue.replaceAll(RegExp(r'[^0-9]'), "");

      if (newValue.length >= 2) {
        newValue =
            '${newValue.substring(0, newValue.length - 2)}.${newValue.substring(newValue.length - 2)}';
      } else {
        newValue = '0.${newValue.padLeft(2, '0')}';
      }

      // Handle cases where newValue starts with '.'
      if (newValue.startsWith('.')) {
        newValue = '0$newValue';
      }

      // Remove any leading zeros that are not followed by a decimal
      newValue = newValue.replaceFirst(RegExp('^0+(?!\\.)'), '');

      // Append the prefix
      if (negative) {
        newValue = '- $prefix $newValue';
      } else {
        newValue = '$prefix $newValue';
      }

      return newValue;
    } catch (e) {
      return 'RM 0.00';
    }
  }

  static String toDoubleString(double value, [String prefix = "RM"]) {
    // Remove all non-numeric characters
    var negative = value < 0;
    var newValue = value.toStringAsFixed(2).replaceAll(RegExp(r'[^0-9]'), "");

    if (newValue.length >= 2) {
      newValue =
          '${newValue.substring(0, newValue.length - 2)}.${newValue.substring(newValue.length - 2)}';
    } else {
      newValue = '0.${newValue.padLeft(2, '0')}';
    }

    // Handle cases where newValue starts with '.'
    if (newValue.startsWith('.')) {
      newValue = '0$newValue';
    }

    // Remove any leading zeros that are not followed by a decimal
    newValue = newValue.replaceFirst(RegExp('^0+(?!\\.)'), '');

    // Append the prefix
    if (negative) {
      newValue = '- $prefix $newValue';
    } else {
      newValue = '$prefix $newValue';
    }

    return newValue;
  }

  static String dateFormat(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  static bool isSameMonthYear(DateTime? date) {
    if (date == null) {
      return false;
    }
    return (date.month == DateTime.now().month &&
        date.year == DateTime.now().year);
  }


static bool isToday(DateTime? date) {
    if (date == null) {
      return false;
    }
    return (date.month == DateTime.now().month &&
        date.year == DateTime.now().year && date.day == DateTime.now().day);
  }
  static double getAmountFromRM(String value) {
    return double.tryParse(value.replaceAll('RM', '').replaceAll(' ', '')) ??
        0.0;
  }

  static void implement_RM_format(
      TextEditingController controller, String value,
      {bool negative = false}) {
    controller.text = FormatterHelper.toFixed2(value, negative: negative);
  }

  static String getMonthName(int month) {
  const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return monthNames[month - 1]; // Subtract 1 since the list is 0-based
}

}
