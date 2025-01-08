import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonBackgroundPainter extends CustomPainter {
  final Color color;

  HexagonBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final highlightPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    final hexagonSize = ResStyle.spacing * 2;
    final horizontalSpacing = hexagonSize * 1.73;
    final verticalSpacing = hexagonSize * 1.5;

    void drawCluster(double startX, double startY, bool isRightSide,
        {bool isTop = true}) {
      final clusterSize = 5;

      for (int row = 0; row < clusterSize; row++) {
        // For right cluster, start with fewer hexagons and increase
        // For left cluster, start with more hexagons and decrease
        int colCount = isRightSide
            ? clusterSize - row % 2 // Right cluster grows from 1 to 4
            : clusterSize - row; // Left cluster shrinks from 4 to 1

        if (!isTop) {
          colCount = 15;
        }
        //colCount =  min(4, colCount);

        for (int col = 0; col < colCount; col++) {
          double xOffset = startX + col * horizontalSpacing;
          // For right cluster, adjust starting X position based on row
          if (isRightSide) {
            xOffset =
                startX + (clusterSize - colCount + col) * horizontalSpacing;
          }
          double yOffset = startY + row * verticalSpacing;

          // Offset alternate rows
          if (row % 2 == 1) {
            xOffset += horizontalSpacing / 2;
          }

          final path = Path();
          for (int i = 0; i < 6; i++) {
            final angle = (i * 60 - 30) * math.pi / 180;
            final x = xOffset + hexagonSize * math.cos(angle);
            final y = yOffset + hexagonSize * math.sin(angle);

            if (i == 0) {
              path.moveTo(x, y);
            } else {
              path.lineTo(x, y);
            }
          }
          path.close();

          // Determine opacity based on position
          final distance = math.sqrt(math.pow(row, 2) + math.pow(col, 2));
          final opacity = 1.0 - (distance / (clusterSize * 1.5));
          final currentPaint = Paint()
            ..color = color.withOpacity(math.max(0.1, opacity))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 + opacity;

          canvas.drawPath(path, currentPaint);
        }
      }
    }

    // Draw left cluster
    drawCluster(ResStyle.width * 0.05, ResStyle.height * 0.1, false);

    // Draw right cluster
    drawCluster(ResStyle.width * 0.75, ResStyle.height * 0.1, true);

   // drawCluster(-50, ResStyle.height * 0.8, false, isTop: false);
    //drawCluster(ResStyle.width * 0.78, ResStyle.height * 0.8, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
