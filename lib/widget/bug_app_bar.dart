import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget BugAppBar(String title) {
  return AppBar(
    backgroundColor: TITLE_COLOR,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        fontSize: ResStyle.body_font,
        fontWeight: FontWeight.bold,
        color: HIGHTLIGHT_COLOR,
      ),
      textAlign: TextAlign.center,
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.account_circle, color: HIGHTLIGHT_COLOR), // Profile icon
        onPressed: () {
          // Add your profile action here
          print("Profile icon pressed");
        },
      ),
    ],
    iconTheme: IconThemeData(color: HIGHTLIGHT_COLOR),
  );
}


SnackBar BugSnackBar(String message, int seconds){
   return SnackBar(
    content: Text(
      message,
      style: TextStyle(
        fontSize: ResStyle.font,
        fontWeight: FontWeight.bold,
        color: HIGHTLIGHT_COLOR,
      ),
    ),
    backgroundColor: TITLE_COLOR,
    duration: Duration(seconds: seconds), // Adjust the duration as needed
    behavior: SnackBarBehavior.floating, // Optional: makes the snackbar float above content
  );
}