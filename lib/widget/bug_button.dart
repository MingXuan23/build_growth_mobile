import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget BugPrimaryButton(
    {required String text,
    required VoidCallback onPressed,
    Color color = ALTERNATIVE_COLOR}) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded corners
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 2 * ResStyle.spacing, vertical: ResStyle.spacing),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: ResStyle.font),
          ),
        ),
      ),
    ],
  );
}

Widget BugTextButton(
    {required String text,
    required VoidCallback onPressed,
    bool underline = false}) {
  return TextButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 2 * ResStyle.spacing,
          vertical: 1 * ResStyle.spacing), // Adjust padding
    ),
    child: Text(
      text,
      style: TextStyle(
        color: TITLE_COLOR,
        fontSize: ResStyle.font,
        decoration: underline ? TextDecoration.underline : null,
      ), // Set text color to white
    ),
  );
}

Widget BugIconButton({
  required String text,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(
          8.0), // Smaller rounded corners for rectangular shape
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(0.15), // Shadow color and transparency
          blurRadius: 8.0, // Blur radius
          offset: Offset(0, 4), // Shadow position (horizontal and vertical)
        ),
      ],
    ),
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: TITLE_COLOR, size: ResStyle.spacing),
      label: Text(
        text,
        style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.medium_font),
        textAlign: TextAlign.center,
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: ResStyle.spacing,
          vertical: ResStyle.spacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Matching corner radius
        ),
        backgroundColor: HIGHTLIGHT_COLOR, // Optional: Background color
      ),
    ),
  );
}

Widget BugPageIndicator(PageController page_controller, int page_count) {
  return SmoothPageIndicator(
    controller: page_controller, // PageController for the PageView
    count: page_count, // Number of pages
    effect: ExpandingDotsEffect(
      dotHeight: ResStyle.spacing,
      dotWidth: ResStyle.spacing,
      activeDotColor: TITLE_COLOR,
      dotColor: PRIMARY_COLOR,
    ),
  );
}
