import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color PRIMARY_COLOR = Color(0xFFA1ABB3);
const Color SECONDARY_COLOR = Color(0xFF565D6D);

const Color HIGHTLIGHT_COLOR = Color(0xFFFAF9F9);


const Color WHITE_TEXT_COLOR = Color(0xFFFAF9F9);

const Color TEXT_COLOR = Color(0xFF1D191A);
const Color TITLE_COLOR = Color(0xFF3A3F4A);

const Color ICON_BUTTON_COLOR = Color(0xFF3A3F4A);

//const Color RM1_COLOR = Color(0xFF819FCF);
const Color RM1_COLOR = Color(0xFF9BB7DE);

const Color RM5_COLOR = Color(0xFF91BFA9);
const Color RM10_COLOR = Color(0xFFFF8E80);
const Color RM20_COLOR = Color(0xFFF0DC82);
const Color RM50_COLOR = Color(0xFF8A9EB4);
const Color RM100_COLOR = Color(0xFF9C879E);

const Color ALTERNATIVE_COLOR = Color(0xFF197DCA);

const Color SUCCESS_COLOR = Color(0xFF91BFA9);
const Color DANGER_COLOR = Color(0xFFC12126);

class ResStyle {
  static bool _initialised = false;
  static double height = 0.0;
  static double width = 0.0;
  static const double _font_size = 0.00006;
  static const double _header_size = 0.0001;
  static const double _body_size = 0.00008;
  static const double _medium_size = 0.00005;
  static const double _small_size = 0.00004;

  static double font = 0.0;
  static double header_font = 0.0;
  static double body_font = 0.0;
  static double small_font = 0.0;
  static double medium_font = 0.0;

  static double spacing =0.0;

  static bool isVertical = true;


  static void initialise(double width, double height) {
    if (_initialised) {
      return;
    }
    ResStyle.width = width;
    ResStyle.height = height;
    var pixels = min(500000, width * height) ;

    if(pixels >=400000){
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    // Adjust text size based on screen width
    font = pixels * _font_size;

    header_font = pixels * _header_size ;

    body_font = pixels * _body_size;
    small_font = pixels * _small_size;
    medium_font = pixels * _medium_size;

    spacing =  (max(height, width) * 0.02).floor().toDouble();
    _initialised =true;

  }
}


// Widget _buildGradientContainer() {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           colors: [
//             Colors.blue[400]!,
//             Colors.blue[600]!,
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//       ),
//     );
//   }