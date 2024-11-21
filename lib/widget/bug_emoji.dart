import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

Widget BugEmoji({
  String avatar = 'lib/assets/bug_emoji3.png',
  String name = 'BUG Helper',
  String message = 'Hallo\n banaosc\nasda',
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: ResStyle.spacing*4,
          width: ResStyle.spacing*4,
    
            decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(avatar),
              fit: BoxFit.fill),
          color: RM20_COLOR,
          shape: BoxShape.circle,
        )),
        SizedBox(width:ResStyle.spacing,),
        Expanded(
          child: Container(
           width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[100], // Different color for left/right
              borderRadius:
                  BorderRadius.circular(16), // Round the corners of the chat bubble
            ),
            padding: EdgeInsets.all(ResStyle.spacing/2),
            child: Text(
              name + ": " + message,
            ),
          ),
        ),
      ],
    ),
  );
}
