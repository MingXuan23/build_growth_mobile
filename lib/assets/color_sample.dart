import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

class ColorDisplayPage extends StatelessWidget {
  final List<Map<String, Color>> colors = [
    {'Primary': PRIMARY_COLOR},
    {'Secondary': SECONDARY_COLOR},
    {'Highlight': HIGHTLIGHT_COLOR},
    {'Text': TEXT_COLOR},
    {'Title': TITLE_COLOR},
    {'Icon Button': ICON_BUTTON_COLOR},
    {'RM1': RM1_COLOR},
    {'RM5': RM5_COLOR},
    {'RM10': RM10_COLOR},
    {'RM20': RM20_COLOR},
    {'RM50': RM50_COLOR},
    {'RM100': RM100_COLOR},
    {'Alternative': ALTERNATIVE_COLOR},
    {'Success': SUCCESS_COLOR},
    {'Danger': DANGER_COLOR},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Display"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final colorName = colors[index].keys.first;
            final colorValue = colors[index][colorName]!;
            return Container(
              color: colorValue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      colorName,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      colorName,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}