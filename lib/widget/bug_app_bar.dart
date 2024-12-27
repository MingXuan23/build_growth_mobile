import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/bloc/content/content_bloc.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/bloc/message/message_bloc.dart';
import 'package:build_growth_mobile/pages/auth/profile_page.dart';
import 'package:build_growth_mobile/pages/widget_tree/start_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

PreferredSizeWidget BugAppBar(String title, BuildContext context,
    {bool show_icon = true}) {
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
      if (show_icon)
        IconButton(
          icon: Icon(Icons.account_circle,
              color: HIGHTLIGHT_COLOR), // Profile icon
          onPressed: () {
            redirectToProfile(context, false);
          },
        ),
    ],
    iconTheme: IconThemeData(color: HIGHTLIGHT_COLOR),
  );
}

void redirectToProfile(BuildContext context, bool gotoPrivacy) async {
  await Navigator.of(context).push(new MaterialPageRoute(
      builder: (context) => ProfilePage(
            gotoPrivacy: gotoPrivacy,
          )));

 BlocProvider.of<FinancialBloc>(context).add(FinancialLoadData());
  BlocProvider.of<ContentBloc>(context).add(ContentRequest());

  BlocProvider.of<MessageBloc>(context).add(CheckMessageEvent());

  FocusScope.of(context).unfocus();

  return;
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
    backgroundColor: HIGHTLIGHT_COLOR,
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

Widget BugBottomModal(
    {required BuildContext context,
    required String header,
    required List<Widget> widgets,
    double additionHeight = 0,
    Key? key}) {
  return SingleChildScrollView(
    key: key,
    child: Container(
      //color: HIGHTLIGHT_COLOR,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: ResStyle.spacing,
        right: ResStyle.spacing,
        top: ResStyle.spacing,
      ),

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28), color: HIGHTLIGHT_COLOR),

      child: Container(
        height: ResStyle.height * 0.7 + additionHeight,
        width: double.infinity,
        color: HIGHTLIGHT_COLOR,
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

void showTopSnackBar(BuildContext context, String message, int seconds) {
  if (!context.mounted) {
    return;
  }

  try {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top +
            kToolbarHeight +
            10, // Adjust for status bar
        left: ResStyle.spacing,
        right: ResStyle.spacing,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: ResStyle.spacing, vertical: ResStyle.spacing),
            decoration: BoxDecoration(
                color: HIGHTLIGHT_COLOR,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TITLE_COLOR, width: 5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.info,
                  color: RM1_COLOR,
                  size: ResStyle.header_font,
                ),
                SizedBox(
                  width: ResStyle.spacing,
                ),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: ResStyle.font,
                      fontWeight: FontWeight.bold,
                      color: TEXT_COLOR,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    try {
                      overlayEntry.remove();
                    } catch (e) {}
                  },
                  child: Icon(
                    Icons.close,
                    size: ResStyle.header_font,
                    color: TITLE_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: seconds)).then((_) {
      if (overlay.mounted) {
        try {
          overlayEntry.remove();
        } catch (e) {
          debugPrint('Error removing overlay after delay: $e');
        }
      }
    });
  } catch (e) {}
}
