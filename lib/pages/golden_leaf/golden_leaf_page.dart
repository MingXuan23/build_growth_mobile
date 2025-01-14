import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/gold_leaf_bloc/gold_leaf_bloc.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

class GoldenLeafPage extends StatefulWidget {
  const GoldenLeafPage({super.key});

  @override
  State<GoldenLeafPage> createState() => _GoldenLeafPageState();
}

class _GoldenLeafPageState extends State<GoldenLeafPage>
    with SingleTickerProviderStateMixin {
  late List<Offset> leafPositions;
  double centerX = 0;
  double centerY = 0;
  final double radius = ResStyle.spacing * 6;
  final int numberOfLeaves = 8;

  late AnimationController _mainController;
  late Animation<double> _mainAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    GoldLeafBloc.leaf;
    BlocProvider.of<GoldLeafBloc>(context).add(LoadGoldLeafEvent());
  }

  void _initializeAnimation() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _mainAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );
  }

  void _initializeLeafPositions(double leafAreaHeight) {
    // Calculate center based on leaf area (top 2/3)
    centerX = ResStyle.width / 2 - ResStyle.spacing;
    centerY = leafAreaHeight / 2;

    leafPositions = List.generate(numberOfLeaves, (index) {
      double angle = 2 * pi * index / numberOfLeaves - (pi / 2);
      double randRadius = ResStyle.spacing * 7;
      return Offset(
        centerX + randRadius * cos(angle),
        centerY + randRadius * sin(angle),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final totalHeight = ResStyle.height - appBarHeight * 2;
    final leafAreaHeight = (totalHeight / 2); // Top 2/3 of available space
    //  final missionAreaHeight = totalHeight / 2; // Bottom 1/3 of available space

    _initializeLeafPositions(leafAreaHeight);

    var center_radius = ResStyle.spacing * 5;
    var small_radius = ResStyle.spacing * 3;

    return Scaffold(
      appBar: BugAppBar('BUild Growth', context),
      body: BlocConsumer<GoldLeafBloc, GoldLeafState>(
        listener: (context, state) {
          if (state is GoldLeafCompletedState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(BugSnackBar(state.message, 5));
          }
        },
        builder: (context, state) {
          List<String> completedMissionList = GoldLeafBloc.completedMissionList;
          List<String> pendingMissionList = GoldLeafBloc.pendingMissionList;
          GoldLeafBloc.leaf;

          return Container(
            width: ResStyle.width,
            height: totalHeight,
            decoration: BoxDecoration(

                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [Colors.green.shade100, Colors.green.shade200],
                // ),
                ),
            child: Column(
              children: [
                Padding(
                  padding:  EdgeInsets.only( top:ResStyle.spacing, left: ResStyle.spacing, right: ResStyle.spacing),
                  child: Text(
                    (GoldLeafBloc.leaf?.totalSubLeaf == 8)
                        ? (GoldLeafBloc.collected)
                            ? "Golden Leaf collected! You can collect more tomorrow."
                            : "Tap the Golden Leaf to collect it now."
                        : "Collect 8 leaves to unlock the Golden Leaf at the center.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: ResStyle.small_font, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(ResStyle.spacing),
                  child: Container(
                    height: leafAreaHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.green.shade100, Colors.green.shade200],
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _mainAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _mainAnimation.value,
                          child: Stack(
                            // Remove alignment: Alignment.center to use absolute positioning
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: Size(ResStyle.width, leafAreaHeight),
                                painter: LeafConnectionsPainter(
                                  leafPositions,
                                  centerX,
                                  centerY,
                                  //animation: _mainAnimation,
                                ),
                              ),
                              if (state is GoldLeafLoadingState)
                                Positioned(
                                  right: ResStyle.spacing,
                                  top: ResStyle.spacing,
                                  child: CircularProgressIndicator(
                                    color:
                                        Colors.white, // Set the color to white
                                  ),
                                ),
                              Positioned(
                                left: centerX - center_radius / 2,
                                top: centerY - center_radius / 2,
                                child: GoldenLeafNode(
                                  radius: center_radius,
                                  //animation: _mainAnimation,
                                ),
                              ),
                              ...List.generate(numberOfLeaves, (index) {
                                return Positioned(
                                  left: leafPositions[index].dx -
                                      small_radius / 2,
                                  top: leafPositions[index].dy -
                                      small_radius / 2,
                                  child: LeafNode(
                                    index: index,
                                    radius: small_radius,
                                    // parentAnimation: _mainAnimation,
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    key: TutorialHelper.goldleafKeys[2],
                    padding: EdgeInsets.symmetric(horizontal: ResStyle.spacing),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, // Consistent container width
                        children: [
                          // Pending Missions
                          if (pendingMissionList.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.all(ResStyle.spacing / 2),
                              decoration: BoxDecoration(
                                color: RM20_COLOR.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: RM20_COLOR,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pending Missions',
                                    style: TextStyle(
                                      fontSize: ResStyle.medium_font,
                                      fontWeight: FontWeight.bold,
                                      color: TITLE_COLOR,
                                    ),
                                  ),
                                  SizedBox(height: ResStyle.spacing / 2),
                                  ...pendingMissionList
                                      .map((mission) => Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: ResStyle.spacing / 8),
                                            child: Text(
                                              mission,
                                              style: TextStyle(
                                                fontSize: ResStyle.small_font,
                                                color: TITLE_COLOR,
                                              ),
                                            ),
                                          )),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: ResStyle.spacing),
                          // Completed Missions
                          if (completedMissionList.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.all(ResStyle.spacing / 2),
                              decoration: BoxDecoration(
                                color: SUCCESS_COLOR.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: SUCCESS_COLOR,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Completed Missions',
                                    style: TextStyle(
                                      fontSize: ResStyle.medium_font,
                                      fontWeight: FontWeight.bold,
                                      color: LOGO_COLOR,
                                    ),
                                  ),
                                  SizedBox(height: ResStyle.spacing / 2),
                                  ...completedMissionList
                                      .map((mission) => Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: ResStyle.spacing / 8),
                                            child: Text(
                                              mission,
                                              style: TextStyle(
                                                fontSize: ResStyle.small_font,
                                                color: TITLE_COLOR,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor: TITLE_COLOR
                                                    .withOpacity(0.7),
                                                decorationThickness: 2,
                                              ),
                                            ),
                                          )),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
              color: ((GoldLeafBloc.leaf?.totalSubLeaf ?? 0) > widget.index)
                  ? Colors.green.shade400
                  : PRIMARY_COLOR,
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
            child: Icon(Icons.eco,
                color: (GoldLeafBloc.leaf?.totalSubLeaf ?? 0) > widget.index
                    ? Colors.green.shade100
                    : TITLE_COLOR,
                size: widget.radius * 0.7),
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

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
            key: TutorialHelper.goldleafKeys[3],
              width: widget.radius,
              height: widget.radius,
              decoration: BoxDecoration(
                color: (GoldLeafBloc.leaf?.totalSubLeaf == 8)
                    ? (GoldLeafBloc.collected)
                        ? Colors.amber
                        : HIGHTLIGHT_COLOR
                    : PRIMARY_COLOR,
                shape: BoxShape.circle,
                border: Border.all(
                    color: (GoldLeafBloc.leaf?.totalSubLeaf == 8
                        ? RM20_COLOR
                        : TITLE_COLOR),
                    width: 3),
                boxShadow: [
                  BoxShadow(
                    color: GoldLeafBloc.leaf?.totalSubLeaf == 8
                        ? Colors.amber.withOpacity(0.3)
                        : HIGHTLIGHT_COLOR.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: BlocBuilder<GoldLeafBloc, GoldLeafState>(
                  builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    if (state is GoldLeafLoadingState) {
                      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar(
                          'Please wait while your data is fetching', 2));
                      return;
                    }

                    if (GoldLeafBloc.collected) {
                      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar(
                          "You've already collected today's Golden Leaf! ", 2));
                      return;
                    }
                    if ((GoldLeafBloc.leaf?.totalSubLeaf ?? 0) >= 8) {
                      BlocProvider.of<GoldLeafBloc>(context)
                          .add(CompleteGoldLeafEvent());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar(
                          'Collect all the leave to unlock the Golden Leaf',
                          5));
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: ResStyle.spacing * 3,
                        height: ResStyle.spacing * 3,
                        child: (GoldLeafBloc.leaf?.totalSubLeaf ?? 0) >= 8
                            ? Image.asset('lib/assets/goldleaf.png')
                            : Image.asset('lib/assets/inactive_goldleaf.png'),
                      ),
                    ],
                  ),
                );
              })),
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
