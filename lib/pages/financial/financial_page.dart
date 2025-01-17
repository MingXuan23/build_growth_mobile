//import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/bloc/gold_leaf_bloc/gold_leaf_bloc.dart';
import 'package:build_growth_mobile/pages/golden_leaf/golden_leaf_page.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/pages/financial/TransactionPage2.dart';
import 'package:build_growth_mobile/pages/financial/asset_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/debt_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/flow_graph.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:build_growth_mobile/widget/bug_design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({Key? key}) : super(key: key);
  static PageController financialPageController =
      PageController(viewportFraction: 1.0);
  @override
  _FinancialPageState createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  // You can add state variables here
  double totalAssets = 0; // Example variable
  double totalDebts = 0; // Example variable
  double totalCashFlow = 0;
  double totalExpense = 0;
  double alarming_limit = 0;
  int debtCount = 0;
  List<Transaction> transaction_history = [];
  List<Transaction> cashFlow_history = [];

  //static PageController financialPageController = PageController(viewportFraction: 1.0);
  List<Widget> quick_actions = [];

  double? graph_selected_value;
  int? graph_selected_index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quick_actions = [
      BugIconGradientButton(
          text: "Manage Asset",
          onPressed: () {
            pushPage(const AssetDetailPage());
          },
          icon: Icons.monetization_on),
      BugIconGradientButton(
          text: "Manage Debt",
          onPressed: () {
            pushPage(const DebtDetailPage());
          },
          icon: Icons.payment),
      BugIconGradientButton(
          text: "Asset Transfer",
          onPressed: () {
            pushPage(TransactionPage2(intention: 'Asset Transfer'));
          },
          icon: Icons.tap_and_play),
      BugIconGradientButton(
          text: "Transaction History",
          onPressed: () {
            pushPage(TransactionHistoryPage());
          },
          icon: Icons.book_online_outlined),
    ];
    BlocProvider.of<FinancialBloc>(context).add(FinancialLoadData());
  }

  // Future<void> loadData() async {
  //   totalAssets = await Asset.getTotalAsset();
  //   totalDebts = await Debt.getTotalDebt();
  //   setState(() {});
  // }

  Future<void> pushPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    BlocProvider.of<FinancialBloc>(context).add(FinancialLoadData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinancialBloc, FinancialState>(
        listener: (context, state) async {
          if (state is FinancialDataLoaded) {
            totalAssets = state.totalAssets;
            totalDebts = state.totalDebts;
            transaction_history = state.transactionList;
            cashFlow_history = state.cashflowTransactionList;
            totalCashFlow = state.totalCashflow;
            totalExpense = state.totalExpense;
            debtCount = state.unpaidDebt;
          }
          alarming_limit = 0;
          var debt_with_alarming = transaction_history
              .where((e) =>
                  e.debt != null &&
                  (e.debt?.status ?? false) &&
                  (e.debt?.alarming_limit ?? 0) > 0)
              .map((e) => e.debt)
              .toSet()
              .toList();

          for (var d in debt_with_alarming) {
            final t = transaction_history
                .where((e) =>
                    e.debt_id == (d?.id ?? 0) &&
                    FormatterHelper.isSameMonthYear(
                        e.created_at)) // Filter by debt_id
                .map((e) => e.amount) // Extract the amount
                .reduce((a, b) => a + b); // Sum the amounts

            alarming_limit += max(0.00, t.abs() - (d?.alarming_limit ?? 0.0));
          }

          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {});
        },
        child: vertical_body());
  }

  Widget AssetDebtSection() {
    return Padding(
      padding: EdgeInsets.all(ResStyle.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Assets Card

          // Expanded(
          //   key: TutorialHelper.financialKeys[1],
          //   flex: 2,
          //   child: FoodCourtCard(
          //      name:  'Total Assets',
          //     value :'${totalAssets.toStringAsFixed(2)}',
          //     onTap: () => pushPage(const AssetDetailPage()),
          //   ),
          // ),

          Row(
            children: [
              Expanded(
                key: TutorialHelper.financialKeys[2],
                child: DebtCard('Debts', 'RM${totalDebts.toStringAsFixed(2)}',
                    () => pushPage(const DebtDetailPage()),
                    color: (debtCount == 0) ? RM5_COLOR : TITLE_COLOR,
                    infotext: (debtCount > 0)
                        ? '$debtCount ${debtCount > 1 ? "Debts" : "Debt"} Remaining'
                        : 'Cleared',
                    font_color:
                        (debtCount == 0) ? TEXT_COLOR : WHITE_TEXT_COLOR,
                    icon: Icons.assignment),
              ),
            ],
          ),
          SizedBox(
            height: ResStyle.spacing / 2,
          ),
          Row(
            children: [
              Expanded(
                key: TutorialHelper.financialKeys[3],
                child: DebtCard(
                    'Expenses',
                    'RM${totalExpense.abs().toStringAsFixed(2)}',
                    () => pushPage(const DebtDetailPage()),
                    color: (alarming_limit > 0) ? DANGER_COLOR : RM5_COLOR,
                    infotext:
                        (alarming_limit > 0) ? 'Over Limit' : 'Safe Limit',
                    font_color:
                        (alarming_limit > 0) ? WHITE_TEXT_COLOR : TEXT_COLOR,
                    icon: Icons.price_change_rounded),
              ),
            ],
          )

          // Total Debts Card
        ],
      ),
    );
  }

  Widget QuickActionSection(int column) {
    return Padding(
      padding: EdgeInsets.all(ResStyle.spacing),
      child: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: quick_actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: column,
            mainAxisSpacing: ResStyle.spacing,
            crossAxisSpacing: ResStyle.spacing,
            childAspectRatio: 2, // Maintain a 1:1 aspect ratio
          ),
          itemBuilder: (context, index) {
            return SizedBox.expand(
              key: TutorialHelper.financialKeys[4 + index],
              child: quick_actions[index],
            );
          },
        ),
      ),
    );
  }

  Widget horizontal_body() {
    return Scaffold(
      backgroundColor: HIGHTLIGHT_COLOR,
      appBar: BugAppBar("Financial Page", context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Total Assets Card
              Expanded(
                flex: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight, // Match parent height
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              AssetDebtSection(), // Page 1
                              TransactionGraphSection(
                                gkey: TutorialHelper.financialKeys[8],
                                transactions: cashFlow_history,
                                currentAsset: totalCashFlow,
                                header: 'Cash Flow History',
                              ),
                              TransactionGraphSection(
                                transactions: transaction_history,
                                currentAsset: totalAssets,
                                header: 'Asset Flow History',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Chart Card
              Expanded(child: QuickActionSection(1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget vertical_body() {
    return PopScope(
      onPopInvoked: (didPop){
        showDialog(context: context, builder: (context) {
        return Text('test');
      },);
      },
      child: Scaffold(
        backgroundColor: HIGHTLIGHT_COLOR, // Maintains the plain background color
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none, // Allow overflow for negative positioning
            children: [
              // Background painter
              Positioned.fill(
                child: CustomPaint(
                  painter: HexagonBackgroundPainter(color: RM1_COLOR),
                ),
              ),
              // Custom AppBar in Stack
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BugAppBarWithContainer(
                  'Financial Page',
                  context,
                ),
              ),
              // Asset Card positioned above the AppBar
              Positioned(
                top: ResStyle.height * 0.15 -
                    ResStyle.spacing * 4, // Adjust to place above the AppBar
                left: ResStyle.spacing * 2,
                right: ResStyle.spacing * 2,
                child: SizedBox(
                  //height: ResStyle.spacing * 5,
                  child: Column(children: [
                    AssetCard(
                      'Total Assets',
                      'RM${totalAssets.toStringAsFixed(2)}',
                      fontColor: LOGO_COLOR,
                      gkey: TutorialHelper.financialKeys[1],
                      () => pushPage(const AssetDetailPage()),
                    )
                  ]),
                ),
              ),
      
              // Body content below the AssetCard
      
              Padding(
                padding: EdgeInsets.only(
                    top: ResStyle.height *
                        0.16), // Push body content below the AssetCard
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: ResStyle.spacing * 1,
                    ),
                    Center(
                      child: BugPageIndicator(
                        FinancialPage.financialPageController,
                        4,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: PageView(
                        controller: FinancialPage.financialPageController,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          AssetDebtSection(),
                          GoldenLeafSection(header: 'BUild Growth'),
                          TransactionGraphSection(
                            key: TutorialHelper.financialKeys[8],
                            transactions: cashFlow_history,
                            currentAsset: totalCashFlow,
                            header: 'Cash Flow History',
                          ),
                          TransactionGraphSection(
                            transactions: transaction_history,
                            currentAsset: totalAssets,
                            header: 'Asset Flow History',
                          ),
                        ],
                      ),
                    ),
                    QuickActionSection(2),
                    SizedBox(
                      height: ResStyle.spacing,
                    ),
                    // Expanded(flex: 1, child: Container(),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionGraphSection extends StatelessWidget {
  final double currentAsset;
  final String header;
  final GlobalKey? gkey;
  final List<Transaction> transactions;

  const TransactionGraphSection(
      {Key? key,
      required this.currentAsset,
      required this.transactions,
      this.gkey,
      required this.header})
      : super(key: key);

  List<FlSpot> _calculateReverseCashFlowSpots() {
    List<FlSpot> spots = [];
    double backwardAsset = currentAsset;

    // Start with current asset
    spots.add(FlSpot(transactions.length.toDouble(), backwardAsset));

    // Calculate backward from the latest transaction
    for (int i = transactions.length - 1; i >= 0; i--) {
      // Reverse the transaction to calculate previous asset value
      backwardAsset -= transactions[i].amount;
      spots.add(FlSpot(i.toDouble(), backwardAsset));
    }

    // Reverse the spots to maintain chronological order
    return spots.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = _calculateReverseCashFlowSpots();

    return Padding(
      padding: EdgeInsets.all(ResStyle.spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    color: TITLE_COLOR),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: ResStyle.medium_font,
                      color: HIGHTLIGHT_COLOR,
                      fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
          Container(
            key: gkey,
            height: ResStyle.height * 0.25,
            padding: EdgeInsets.symmetric(
                vertical: ResStyle.spacing, horizontal: ResStyle.spacing * 1.5),
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
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    curve: Curves.bounceIn,
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        show: false,
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
                        touchSpotThreshold: 100,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              return LineTooltipItem(
                                FormatterHelper.toDoubleString(touchedSpot.y),
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
                SizedBox(
                  height: ResStyle.spacing * 1,
                ),
                BugSmallButton(
                    text: 'Details',
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TransactionGraphPage(
                                currentAsset: currentAsset,
                                transactions: transactions,
                                header: header,
                              )));

                      FocusScope.of(context).unfocus();
                      FocusManager.instance.primaryFocus?.unfocus();
                      BlocProvider.of<FinancialBloc>(context)
                          .add(FinancialLoadData());
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GoldenLeafSection extends StatefulWidget {
  final String header;

  final GlobalKey? gkey;

  const GoldenLeafSection({
    Key? key,
    this.gkey,
    required this.header,
  }) : super(key: key);

  @override
  State<GoldenLeafSection> createState() => _GoldenLeafSectionState();
}

class _GoldenLeafSectionState extends State<GoldenLeafSection>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 800));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.repeat(reverse: true);
  }

  String getTitle(Map<String, dynamic> leafData) {
    String title = "NewBie";

    // Check for rank-based titles
    if (leafData['rank'] != null) {
      var rank = leafData['rank'];
      if (rank == 1) {
        title = "Golden Champion"; // First place collector
      } else if (rank <= 10) {
        title = "Elite Collector"; // Top 10
      } else if (rank <= 100) {
        title = "Top 100 Achiever"; // Top 100
      }
    }
    // Check for percentage-based titles
    else if (leafData['percent'] != null) {
      var percent = leafData['percent'];
      if (percent >= 90) {
        title = "Wealthiest Collector"; // Top 10% globally
      } else if (percent >= 70) {
        title = "Golden Enthusiast"; // Top 30% globally
      } else if (percent >= 50) {
        title = "Solid Contributor"; // Above average
      }
    }
    // Check for total leaf-based titles
    else if (leafData['total_leaf'] != null) {
      var totalLeaf = leafData['total_leaf'];
      if (totalLeaf >= 1000) {
        title = "Master of Leaves"; // Over 1000 leaves
      } else if (totalLeaf >= 365) {
        title = "Year-Round Collector"; // Over a year
      } else if (totalLeaf >= 100) {
        title = "Centennial Collector"; // Over 100 leaves
      } else if (totalLeaf >= 30) {
        title = "Consistent Achiever"; // Over a month
      } else if (totalLeaf >= 7) {
        title = "Weekly Warrior"; // Over a week
      }
    }

    return title;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _takeScreenshotAndShare() async {
    try {
      setState(() {
        isCapturing = true; // Hide buttons during capture
      });

      await Future.delayed(Duration(milliseconds: 30));
      BlocProvider.of<GoldLeafBloc>(context).add(ShareGoldLeafEvent());
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final directory = await Directory.systemTemp.createTemp();
        final filePath = '${directory.path}/gold_leaf_achievement.png';
        final file = File(filePath)..writeAsBytesSync(imageBytes);

        await Share.shareXFiles([XFile(file.path)],
            text: 'BUild Growth with me together!\n\n' +'See my achievement today: ${getTitle(GoldLeafBloc.leafData)}'+  (GoldLeafBloc.leafData['rank'] == null || GoldLeafBloc.leafData['rank'] ==-1
                        ? ".\n\nHurry up to collect the Golden Leaf with me!"
                        : ".\n\nI am the top ${GoldLeafBloc.leafData['rank']} collectors today ") +
                    "and ahead of ${GoldLeafBloc.leafData['percent'] ?? 0.01}% of Golden Leaf collectors!\n\nJoin me at https://play.google.com/store/apps/details?id=com.bug.build_growth_mobile",);
      }
    } catch (e) {
      debugPrint("Error capturing or sharing screenshot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share your achievement.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isCapturing = false; // Hide buttons during capture
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedCount = "0";
    String title = getTitle(GoldLeafBloc.leafData);
    if (GoldLeafBloc.leafData['total_leaf'] != null) {
      var count = GoldLeafBloc.leafData['total_leaf'];
      formattedCount = count >= 1000
          ? "${(count / 1000).toStringAsFixed(1)}K"
          : count.toString();
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Main content container
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  key: widget.gkey,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        HIGHTLIGHT_COLOR,
                        HIGHTLIGHT_COLOR.withOpacity(0.95),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: RM20_COLOR,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TEXT_COLOR.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(ResStyle.spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Achievement display
                        if(isCapturing)
                          Row(
                            children: [
                              Container(
                                width: ResStyle.spacing*3,
                                height: ResStyle.spacing* 3,
                                child: Image.asset('lib/assets/playstore-icon.png'),
                              ),
                            ],
                          ),
                        _buildAchievementDisplay(formattedCount, title),
                        SizedBox(height: ResStyle.spacing / 2),
                        // Buttons for actions
                        if (!isCapturing)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEnhancedButton(
                                gkey:  TutorialHelper.goldleafKeys[1],
                                'Get Leaf',
                                Icons.eco,
                                () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => GoldenLeafPage(),
                                    ),
                                  );
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  BlocProvider.of<FinancialBloc>(context)
                                      .add(FinancialLoadData());
                                },
                              ),
                              SizedBox(width: ResStyle.spacing),
                              _buildEnhancedButton(
                                gkey:  TutorialHelper.goldleafKeys[4],
                                'Share',
                                Icons.share,
                                _takeScreenshotAndShare,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.05,
            colors: [
              RM20_COLOR,
              TITLE_COLOR,
              HIGHTLIGHT_COLOR,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementDisplay(String formattedCount, String title) {
    return Column(
      children: [
        // Golden leaf display
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Glow effect
            Container(
              height: ResStyle.spacing * 6,
              width: ResStyle.spacing * 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    RM20_COLOR.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Animated golden leaf
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                key: TutorialHelper.goldleafKeys[0],
                height: ResStyle.spacing * 6,
                width: ResStyle.spacing * 6,
                child: Image.asset(
                  'lib/assets/goldleaf.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Count display
            Positioned(
              bottom: -10,
              right: -10,
              child: _buildCountDisplay(formattedCount),
            ),
          ],
        ),
        SizedBox(height: ResStyle.spacing / 4),
        // Achievement details
        Container(
          padding: EdgeInsets.all(ResStyle.spacing / 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RM20_COLOR.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: RM20_COLOR),
                  SizedBox(width: ResStyle.spacing / 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResStyle.small_font,
                      color: TEXT_COLOR,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                (GoldLeafBloc.leafData['rank'] == null || GoldLeafBloc.leafData['rank'] ==-1
                        ? "Hurry up to collect the Golden Leaf!"
                        : "You're in the top ${GoldLeafBloc.leafData['rank']} collectors today!") +
                    "\nYou're ahead of ${GoldLeafBloc.leafData['percent'] ?? 0.01}% of collectors!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResStyle.small_font,
                  color: TEXT_COLOR.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountDisplay(String formattedCount) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResStyle.spacing * 10,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResStyle.spacing / 2,
        vertical: ResStyle.spacing / 4,
      ),
      decoration: BoxDecoration(
        color: RM20_COLOR,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TITLE_COLOR.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TEXT_COLOR.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: TITLE_COLOR,
            size: ResStyle.small_font,
          ),
          SizedBox(width: ResStyle.spacing / 4),
          Flexible(
            child: Text(
              formattedCount,
              style: TextStyle(
                fontSize: ResStyle.small_font,
                color: TITLE_COLOR,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildEnhancedButton(
    String text, IconData icon, VoidCallback onPressed, {GlobalKey? gkey}) {
  return Container(
    key: gkey,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [RM20_COLOR, RM20_COLOR.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: TEXT_COLOR.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResStyle.spacing,
            vertical: ResStyle.spacing / 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: TITLE_COLOR, size: 18),
              SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: ResStyle.small_font,
                  color: TITLE_COLOR,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
