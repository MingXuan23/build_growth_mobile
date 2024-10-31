import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget BugAppBar(String title) {
  return AppBar(
    backgroundColor: TITLE_COLOR,
    title: Text(title, style: TextStyle(fontSize: ResStyle.body_font, fontWeight: FontWeight.bold, color: HIGHTLIGHT_COLOR ),),
  );
}
