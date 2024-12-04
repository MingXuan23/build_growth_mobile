import 'dart:async';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
          width: ResStyle.spacing / 2,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ALTERNATIVE_COLOR
                  .withOpacity(0.2), // Different color for left/right
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

class AnimatedBugEmoji extends StatefulWidget {
  final String avatar;
  final String message;
  final Duration duration;

  const AnimatedBugEmoji({
    Key? key,
    this.avatar = 'lib/assets/bug_emoji3.png',
    required this.message,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _AnimatedBugEmojiState createState() => _AnimatedBugEmojiState();
}

class _AnimatedBugEmojiState extends State<AnimatedBugEmoji> {
  late List<String> words;
  String visibleMessage = "";
  int currentWordIndex = 0;
  Timer timer = Timer(Duration.zero, (){});

  @override
  void initState() {
    super.initState();
 
  }

  void _startWordAnimation() {
    if(visibleMessage != ""){
      return;
    }
     //visibleMessage = "";
    words = widget.message.split(" ");
   
    final wordInterval = widget.duration.inMilliseconds ~/ words.length;
    timer = Timer.periodic(Duration(milliseconds: wordInterval), (timer) {
      if (currentWordIndex < words.length) {
        setState(() {
          visibleMessage =
              "${visibleMessage.trim()} ${words[currentWordIndex]}";
          currentWordIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('animate-bug'),
      onVisibilityChanged: (info) {
        var visiblePercentage = info.visibleFraction * 100;
        if (visiblePercentage >= 50) {
          _startWordAnimation();
        }
      },
      child: BugEmoji(message: visibleMessage),
    );

    // return Padding(
    //   padding: EdgeInsets.symmetric(vertical: ResStyle.spacing),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       // Avatar Image
    //       Container(
    //         height: ResStyle.spacing * 2,
    //         width: ResStyle.spacing * 2,
    //         decoration: BoxDecoration(
    //           image: DecorationImage(
    //             image: AssetImage(widget.avatar),
    //             fit: BoxFit.fill,
    //           ),
    //           color: RM20_COLOR,
    //           shape: BoxShape.circle,
    //         ),
    //       ),
    //       SizedBox(
    //         width: ResStyle.spacing / 2,
    //       ),
    //       // Message Bubble
    //       Expanded(
    //         child: Container(
    //           decoration: BoxDecoration(
    //             color: ALTERNATIVE_COLOR.withOpacity(0.2),
    //             borderRadius: const BorderRadius.only(
    //               bottomRight: Radius.circular(16),
    //               topRight: Radius.circular(16),
    //               bottomLeft: Radius.circular(16),
    //             ),
    //           ),
    //           padding: EdgeInsets.all(ResStyle.spacing / 2),
    //           child: Text(
    //             ,
    //             style: TextStyle(
    //               color: Colors.black,
    //               fontSize: ResStyle.body_font,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
