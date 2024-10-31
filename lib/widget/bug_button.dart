  import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';


Widget BugPrimaryButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 2 * ResStyle.spacing, vertical: ResStyle.spacing ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResStyle.font
                ),
              ),
            ),
          ),
        ],
      );
}


Widget BugTextButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return TextButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(horizontal: 2 * ResStyle.spacing, vertical: 1 * ResStyle.spacing), // Adjust padding
    ),
    child: Text(
      text,
      style: TextStyle(color: TITLE_COLOR , fontSize: ResStyle.font), // Set text color to white
    ),
  );
}
