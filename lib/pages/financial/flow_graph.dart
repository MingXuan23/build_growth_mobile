import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionGraphPage extends StatefulWidget {
  final double currentAsset;
  final String header;
  final List<Transaction> transactions;

  const TransactionGraphPage({
    Key? key,
    required this.currentAsset,
    required this.transactions,
    required this.header,
  }) : super(key: key);

  @override
  _TransactionGraphSectionState createState() =>
      _TransactionGraphSectionState();
}

class _TransactionGraphSectionState extends State<TransactionGraphPage> with SingleTickerProviderStateMixin {
  late List<FlSpot> spots;
  late double minX, maxX, minY, maxY;
  late AnimationController _animationController;
late Animation<double> _animation;
  bool _isLandscape = false;
  
  @override
  void initState() {
    super.initState();
    // Force horizontal orientation
spots = _calculateReverseCashFlowSpots();
    _calculateAxisRanges();

      _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceIn,
    );

     WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLandscapeOrientation();
    });
    
  }

 Future<void> _setLandscapeOrientation() async {
    setState(() => _isLandscape = true);
    await _animationController.forward();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

   Future<void> _restoreOrientation() async {
    await    _animationController.reverse();
    

  }


  @override
  void dispose() {
    // Restore orientation to default
   _restoreOrientation();
    _animationController.dispose();
     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  List<FlSpot> _calculateReverseCashFlowSpots() {
    List<FlSpot> spots = [];
    double backwardAsset = widget.currentAsset;

    // Start with current asset
    spots.add(FlSpot(widget.transactions.length.toDouble(), backwardAsset));

    // Calculate backward from the latest transaction
    for (int i = widget.transactions.length - 1; i >= 0; i--) {
      backwardAsset -= widget.transactions[i].amount;
      spots.add(FlSpot(i.toDouble(), backwardAsset));
    }

    // Reverse the spots to maintain chronological order
    return spots.reversed.toList();
  }

  void _calculateAxisRanges() {
    minX = 0;
    maxX = widget.transactions.length.toDouble();

    if (spots.isEmpty) {
      minY = 0;
      maxY = widget.currentAsset;
    } else {
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }

    // Adjust padding to prevent overlap
    double yPadding = (maxY - minY).abs() * 0.15; // Increased padding
    maxY += yPadding;
    minY -= yPadding;

    // Ensure minY is not negative if data doesn't warrant it
    if (minY > 0) minY = 0;
  }

  double _calculateSafeInterval(double min, double max) {
    double rawInterval = (max - min) / 5;
    return rawInterval == 0 ? 1.0 : rawInterval.abs();
  }

  @override
  Widget build(BuildContext context) {
    final graphWidth = max(widget.transactions.length, 15) * 50.0;

    final horizontalInterval = _calculateSafeInterval(minY, maxY);
    final verticalInterval = _calculateSafeInterval(minX, maxX);

    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child){
          return Scaffold(
        appBar: BugAppBar(widget.header, context, show_icon: false),
        backgroundColor: HIGHTLIGHT_COLOR.withOpacity(0.9),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResStyle.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    padding: EdgeInsets.all(ResStyle.spacing),
                    decoration: BoxDecoration(
                      color: HIGHTLIGHT_COLOR,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: TEXT_COLOR.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: graphWidth,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Padding(
                          padding: EdgeInsets.all(ResStyle.spacing),
                          child: LineChart(
                            LineChartData(
                              minX: minX,
                              maxX: maxX,
                              minY: minY,
                              maxY: maxY,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: horizontalInterval,
                                verticalInterval: verticalInterval,
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: horizontalInterval,
                                    reservedSize: ResStyle.width * 0.2,
                                    getTitlesWidget: (value, meta) {
                                      // Format the value to avoid overlapping
                                      if ((value - minY).abs() < 0.01) {
                                        return SizedBox
                                            .shrink(); // Return an empty widget to hide the label
                                      }
                                      return Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: Text(
                                          FormatterHelper.toDoubleString(value),
                                          style: TextStyle(
                                            color: TEXT_COLOR,
                                            fontSize: ResStyle.small_font,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: 0,
                                    color: SECONDARY_COLOR.withOpacity(0.5),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  ),
                                ],
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: PRIMARY_COLOR,
                                  barWidth: 2,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: PRIMARY_COLOR,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: PRIMARY_COLOR.withOpacity(0.1),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchSpotThreshold: 300,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((touchedSpot) {
                                      return LineTooltipItem(
                                        FormatterHelper.toDoubleString(
                                            touchedSpot.y),
                                        TextStyle(
                                          color: HIGHTLIGHT_COLOR,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: ResStyle.spacing,
                // ),
                // BugInfoCard('Incoming Feature')
              ],
            ),
          ),
        ),
      );
        },
      
    );
  }
}
