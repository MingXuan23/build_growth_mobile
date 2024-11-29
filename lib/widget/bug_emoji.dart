import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

Widget BugEmoji({
  String avatar = 'lib/assets/bug_emoji3.png',
  // String name = 'BUG Helper',
  String message = 'Hallo\n banaosc\nasda',
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: ResStyle.spacing * 2,
            width: ResStyle.spacing * 2,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: AssetImage(avatar), fit: BoxFit.fill),
              color: RM20_COLOR,
              shape: BoxShape.circle,
            )),
        SizedBox(
          width: ResStyle.spacing/2,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ALTERNATIVE_COLOR.withOpacity(0.2), // Different color for left/right
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.all(ResStyle.spacing / 2),
            child: Text(
              message,
            ),
          ),
        ),
      ],
    ),
  );
}
