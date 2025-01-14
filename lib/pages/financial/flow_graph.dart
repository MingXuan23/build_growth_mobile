import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
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
  _TransactionGraphSectionState createState() => _TransactionGraphSectionState();
}

class _TransactionGraphSectionState extends State<TransactionGraphPage>
    with SingleTickerProviderStateMixin {
  late List<FlSpot> spots;
  late double minX, maxX, minY, maxY;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLandscape = false;
  
  // Date range state
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _minDate;
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    // Initialize date range
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
    _minDate = widget.transactions.isNotEmpty 
        ? widget.transactions.map((t) => t.created_at).reduce((a, b) => a.isBefore(b) ? a : b)
        : _startDate;
    
    _filterTransactions();
    
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

  void _filterTransactions() {
    _filteredTransactions = widget.transactions.where((transaction) {
      return transaction.created_at.isAfter(_startDate) && 
             transaction.created_at.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
    
    setState(() {
      spots = _calculateReverseCashFlowSpots();
      _calculateAxisRanges();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    var init_date =(isStartDate ? _startDate : _endDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: init_date.isAfter(_minDate)?init_date:_minDate,
      firstDate: _minDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          if (picked.isBefore(_endDate)) {
            _startDate = picked;
            _filterTransactions();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Start date must be before end date')),
            );
          }
        } else {
          if (picked.isAfter(_startDate)) {
            _endDate = picked;
            _filterTransactions();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date must be after start date')),
            );
          }
        }
      });
    }
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
    await _animationController.reverse();
  }

  @override
  void dispose() {
    _restoreOrientation();
    _animationController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  List<FlSpot> _calculateReverseCashFlowSpots() {
    List<FlSpot> spots = [];
    double backwardAsset = widget.currentAsset;

    spots.add(FlSpot(_filteredTransactions.length.toDouble(), backwardAsset));

    for (int i = _filteredTransactions.length - 1; i >= 0; i--) {
      backwardAsset -= _filteredTransactions[i].amount;
      spots.add(FlSpot(i.toDouble(), backwardAsset));
    }

    return spots.reversed.toList();
  }

  void _calculateAxisRanges() {
    minX = 0;
    maxX = _filteredTransactions.length.toDouble();

    if (spots.isEmpty) {
      minY = 0;
      maxY = widget.currentAsset;
    } else {
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }

    double yPadding = (maxY - minY).abs() * 0.15;
    maxY += yPadding;
    minY -= yPadding;

    if (minY > 0) minY = 0;
  }

  double _calculateSafeInterval(double min, double max) {
    double rawInterval = (max - min) / 5;
    return rawInterval == 0 ? 1.0 : rawInterval.abs();
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: EdgeInsets.all(ResStyle.spacing),
      decoration: BoxDecoration(
        color: HIGHTLIGHT_COLOR,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TEXT_COLOR.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BugSmallButton(text: 'From: ${FormatterHelper.dateFormat(_startDate)}', onPressed:  () => _selectDate(context, true)),
           BugSmallButton(text: 'To: ${FormatterHelper.dateFormat(_endDate)}', onPressed: () => _selectDate(context, false),),
         
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphWidth = max(_filteredTransactions.length, 15) * 50.0;

    final horizontalInterval = _calculateSafeInterval(minY, maxY);
    final verticalInterval = _calculateSafeInterval(minX, maxX);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
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
                      height: MediaQuery.of(context).size.height * 0.7,
                      padding: EdgeInsets.all(ResStyle.spacing),
                      decoration: BoxDecoration(
                        color: HIGHTLIGHT_COLOR,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: TEXT_COLOR.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                        if ((value - minY).abs() < 0.01) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 0),
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
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: verticalInterval,
                                      getTitlesWidget: (value, meta) {
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: verticalInterval,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index < 0 ||
                                            index >= _filteredTransactions.length) {
                                          return const SizedBox.shrink();
                                        }

                                        String date = FormatterHelper.dateFormat(
                                          _filteredTransactions[index].created_at,
                                        );

                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            date,
                                            style: TextStyle(
                                              color: TEXT_COLOR,
                                              fontSize: ResStyle.small_font,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
                                      getDotPainter: (spot, percent, barData, index) {
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
                  SizedBox(height: ResStyle.spacing,),
                   _buildDateRangeSelector(),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}