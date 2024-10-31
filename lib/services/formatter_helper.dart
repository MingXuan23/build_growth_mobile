import 'dart:ffi';

class FormatterHelper {
  static String toFixed2(String value, [String prefix = "RM"]) {
    // Remove all non-numeric characters
    String newValue = value.replaceAll(RegExp(r'[^0-9]'), "");

    // Ensure at least two digits for the decimal conversion
    bool negative = double.parse(newValue) < 0;
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

  static String dateFormat(DateTime date){
    return '${date.year}-${date.month}-${date.day}';
  }

  static bool isSameMonthYear(DateTime? date){
    if(date ==null){
      return false;
    }
    return (date.month == DateTime.now().month &&
        date.year == DateTime.now().year);
  }
}
