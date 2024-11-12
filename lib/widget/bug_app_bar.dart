import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/pages/widget_tree/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

PreferredSizeWidget BugAppBar(String title, BuildContext context) {
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
        icon:
            Icon(Icons.account_circle, color: HIGHTLIGHT_COLOR), // Profile icon
        onPressed: () {
          // Add your profile action here
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => StartPage()));
          BlocProvider.of<AuthBloc>(context).add(
            AutoLoginRequest(),
          );
        },
      ),
    ],
    iconTheme: IconThemeData(color: HIGHTLIGHT_COLOR),
  );
}

SnackBar BugSnackBar(String message, int seconds) {
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
    behavior: SnackBarBehavior
        .floating, // Optional: makes the snackbar float above content
  );
}

AlertDialog BugInfoDialog(
    {required String title,
    Color main_color = TITLE_COLOR,
    String message = '',
    Widget? content,
    required List<Widget> actions}) {
  return AlertDialog(
    titlePadding: EdgeInsets.all(0),
    title: Container(
      padding:
          EdgeInsets.all(ResStyle.spacing), // Padding around the title text
      decoration: BoxDecoration(
        color: main_color, // Background color for title section
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        // Rounded corners if desired
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResStyle.header_font,
          fontWeight: FontWeight.bold,
          color: HIGHTLIGHT_COLOR, // Text color for the title
        ),
        textAlign: TextAlign.center,
      ),
    ),
    content: content ??
        Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: Text(
            message,
            style: TextStyle(
              fontSize: ResStyle.font,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
    actions: actions,
  );
}

Widget BugBottomModal({
  required BuildContext context,
  required String header,
  required List<Widget> widgets,
}) {
  return SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: ResStyle.spacing,
        right: ResStyle.spacing,
        top: ResStyle.spacing,
      ),
      child: SizedBox(
        height: ResStyle.height * 0.7,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header container
            Container(
              decoration: const BoxDecoration(
                color: TITLE_COLOR,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: ResStyle.spacing, horizontal: ResStyle.spacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      header,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResStyle.body_font,
                        fontWeight: FontWeight.bold,
                        color: HIGHTLIGHT_COLOR,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HIGHTLIGHT_COLOR,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: ResStyle.spacing,
                        color: TITLE_COLOR,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResStyle.spacing * 2),

            // Scrollable widget list
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (Widget widget in widgets) widget,
                    SizedBox(height: ResStyle.spacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget BugLoading() {
// Default color if not provided

  double size = ResStyle.spacing * 5;
  return Center(
    child: SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(TITLE_COLOR),
        strokeWidth: ResStyle.spacing,
      ),
    ),
  );
}
