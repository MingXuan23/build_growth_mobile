import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget BugPrimaryButton(
    {required String text,
    required VoidCallback onPressed,
    Color color = ALTERNATIVE_COLOR,
    double borderRadius = 30.0}) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius), // Rounded corners
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

Widget BugSmallButton(
    {required String text,
    required VoidCallback onPressed,
    Color color = RM1_COLOR,
    double? font_size,
    double borderRadius = 16.0}) {

      font_size = font_size??ResStyle.small_font;
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(
          horizontal: ResStyle.spacing/2, vertical: ResStyle.spacing/4),
    ),
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize:font_size),
    ),
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

Widget BugIconButton(
    {required String text,
    required IconData icon,
    required VoidCallback onPressed,
    color = HIGHTLIGHT_COLOR,
    text_color = TITLE_COLOR}) {
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
      icon: Icon(icon, color: text_color, size: ResStyle.spacing),
      label: Text(
        text,
        style: TextStyle(color: text_color, fontSize: ResStyle.medium_font),
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
        backgroundColor: color, // Optional: Background color
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

class BugDoubleTapButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool underline;

  const BugDoubleTapButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.underline = false,
  }) : super(key: key);

  @override
  State<BugDoubleTapButton> createState() => _DoubleTapButtonState();
}

class _DoubleTapButtonState extends State<BugDoubleTapButton> {
  DateTime? _lastTapTime;
  bool _isFirstTap = false;

  int second = 2;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) <= Duration(seconds: second)) {
      setState(() {
        _isFirstTap = false;
      });
      widget.onPressed();
      _lastTapTime = null;
    } else {
      _lastTapTime = now;
      setState(() {
        _isFirstTap = true;
      });
      // Reset visual feedback after 2 seconds
      Future.delayed(Duration(seconds: second), () {
        if (mounted) {
          setState(() {
            _isFirstTap = false;
          });
          _lastTapTime = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _isFirstTap ? Colors.grey.withOpacity(0.1) : Colors.transparent,
      ),
      child: BugTextButton(
        onPressed: _handleTap,
        underline: widget.underline,
        text: _isFirstTap ? "Tap again to go back" : widget.text,
      ),
    );
  }
}

Widget BugRoundButton(
    {required IconData icon,
    required VoidCallback onPressed,
    Color color = HIGHTLIGHT_COLOR,
    Color text_color = TITLE_COLOR,
    double size = 50,
    String? label}) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors
              .transparent, // Set transparent for the ElevatedButton background
          shadowColor: Colors.transparent, // Remove shadow for a cleaner look
          padding: EdgeInsets.zero, // Ensure the container determines the size
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: color, // Background color of the circular container
              shape:
                  BoxShape.circle, // Ensures the container is always circular
              border: Border.all(color: text_color, width: 2)),
          alignment: Alignment.center, // Center the icon within the container
          child: Icon(
            icon,
            color: text_color,
            size:
                size * 0.6, // Adjust icon size to fit well within the container
          ),
        ),
      ),
      if (label != null)
        Text(
          label,
          style: TextStyle(
              fontSize: ResStyle.small_font, fontWeight: FontWeight.bold),
        )
    ],
  );
}

class CustomQuarterCircleButton extends StatelessWidget {
  final bool isRight;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;
  final String label;

  const CustomQuarterCircleButton({
    required this.isRight,
    required this.color,
    required this.icon,
    required this.onPressed,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: QuarterCircleClipper(isRight: isRight),
      child: Material(
        //color: color,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: isRight
                    ? Alignment.bottomRight
                    : Alignment.topLeft, // Start gradient from top-left
                end: isRight
                    ? Alignment.bottomLeft
                    : Alignment.topRight, // End gradient at bottom-right
                colors: [
                  color,
                  PRIMARY_COLOR.withOpacity(0.9)
                ], // Define your gradient colors
              ),
            ),
            width: ResStyle.width * 0.3,
            height: ResStyle.width * 0.3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ResStyle.spacing),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Center content vertically
                crossAxisAlignment: isRight
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start, // Center content horizontally
                children: [
                  SizedBox(
                    width: ResStyle.spacing,
                  ),
                  Icon(
                    icon,
                    color: HIGHTLIGHT_COLOR,
                    size: ResStyle.header_font,
                  ),

                  ///SizedBox(height: ResStyle.spacing), // Space between icon and label
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: ResStyle.body_font,
                      color: HIGHTLIGHT_COLOR,
                    ),
                    textAlign:
                        TextAlign.center, // Ensure label text is centered
                  ),
                  SizedBox(
                    height: ResStyle.spacing,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuarterCircleClipper extends CustomClipper<Path> {
  final bool isRight;

  QuarterCircleClipper({required this.isRight});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (isRight) {
      // Left quarter circle (90° to 180°)
      path.moveTo(size.width, 0);
      path.arcToPoint(
        Offset(0, size.height),
        radius: Radius.circular(size.width),
        clockwise: false, // Counter-clockwise for left quarter circle
      );
      path.lineTo(size.width, size.height); // Close the path
    } else {
      // Right quarter circle (0° to 90°)
      path.moveTo(0, 0);
      path.arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.circular(size.width),
        clockwise: true, // Clockwise for right quarter circle
      );
      path.lineTo(0, size.height); // Close the path
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
