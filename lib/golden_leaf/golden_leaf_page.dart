import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GoldenLeafPage extends StatefulWidget {
  const GoldenLeafPage({super.key});

  @override
  State<GoldenLeafPage> createState() => _GoldenLeafPageState();
}

class _GoldenLeafPageState extends State<GoldenLeafPage> {
  late List<Offset> leafPositions;
  double centerX = 200;
  double centerY = 200;
  final double radius = ResStyle.spacing * 8;
  final int numberOfLeaves = 8;

  @override
  void initState() {
    super.initState();
    _initializeLeafPositions();
  }

  void _initializeLeafPositions() {
    leafPositions = List.generate(numberOfLeaves, (index) {
      double angle = 2 * pi * index / numberOfLeaves;
      return Offset(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    centerX = ResStyle.width / 2;
    centerY = (ResStyle.height - 2*appBarHeight) / 2;
    _initializeLeafPositions();

    var center_radius = ResStyle.spacing * 5;
    var small_radius = ResStyle.spacing * 3;
    return Scaffold(
      appBar: BugAppBar('BUild Growth', context),
      body: Container(
        width: ResStyle.width,
        height: ResStyle.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.green.shade200],
          ),
        ),
        child: Stack(
          children: [
            // Connection lines
            CustomPaint(
              size: Size(ResStyle.width, ResStyle.height),
              painter: LeafConnectionsPainter(leafPositions, centerX, centerY),
            ),
            // Center golden leaf
            Positioned(
              left: centerX - center_radius/2,
              top: centerY - center_radius/2,
              child: GoldenLeafNode(radius:  center_radius,),
            ),
            // Surrounding leaves
            ...List.generate(numberOfLeaves, (index) {
              return Positioned(
                left: leafPositions[index].dx - small_radius/2,
                top: leafPositions[index].dy - small_radius/2,
                child: LeafNode(index: index, radius:  small_radius,),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class LeafNode extends StatefulWidget {
  final int index;
  final double radius;
  const LeafNode({super.key, required this.index, required this.radius});

  @override
  State<LeafNode> createState() => _LeafNodeState();
}

class _LeafNodeState extends State<LeafNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.radius,
            height: widget.radius,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade800, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.eco, color: Colors.green.shade100, size: widget.radius * 0.7),
          ),
        );
      },
    );
  }
}

class GoldenLeafNode extends StatefulWidget {
  const GoldenLeafNode({super.key, required this.radius});

  final double radius;
  @override
  State<GoldenLeafNode> createState() => _GoldenLeafNodeState();
}

class _GoldenLeafNodeState extends State<GoldenLeafNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.radius,
            height: widget.radius,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade800, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 60),
          ),
        );
      },
    );
  }
}

class LeafConnectionsPainter extends CustomPainter {
  final List<Offset> leafPositions;
  final double centerX;
  final double centerY;

  LeafConnectionsPainter(this.leafPositions, this.centerX, this.centerY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final position in leafPositions) {
      canvas.drawLine(Offset(centerX, centerY), position, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
