import 'dart:ffi';
import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({Key? key}) : super(key: key);
static PageController financialPageController = PageController(viewportFraction: 1.0);
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
  int debtCount =0;
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
      BugIconButton(
          text: "Manage Asset",
          onPressed: () {
            pushPage(const AssetDetailPage());
          },
          icon: Icons.monetization_on),
      BugIconButton(
          text: "Manage Debt",
          onPressed: () {
            pushPage(const DebtDetailPage());
          },
          icon: Icons.payment),
      BugIconButton(
          text: "Asset Transfer",
          onPressed: () {
            pushPage(TransactionPage2(intention: 'Asset Transfer'));
          },
          icon: Icons.tap_and_play),
      BugIconButton(
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
              .where((e) => e.debt != null && (e.debt?.alarming_limit ?? 0) > 0)
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
          Expanded(
            key: TutorialHelper.financialKeys[1],
            flex: 2,
            child: AssetCard(
              'Total Assets',
              'RM${totalAssets.toStringAsFixed(2)}',
              () => pushPage(const AssetDetailPage()),
            ),
          ),
          SizedBox(height: ResStyle.spacing),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                   key: TutorialHelper.financialKeys[2],
                  child: DebtCard(
                    'Debts',
                    'RM${totalDebts.toStringAsFixed(2)}',
                    () => pushPage(const DebtDetailPage()),
                    color: (debtCount == 0) ? RM5_COLOR : TITLE_COLOR,
                     infotext: (debtCount > 0) ? '(${debtCount} unpaid debt)' : null,
                    font_color:
                        (debtCount == 0) ? TEXT_COLOR : WHITE_TEXT_COLOR,
                  ),
                ),
                Expanded(
                   key: TutorialHelper.financialKeys[3],
                  child: DebtCard(
                    'Expenses',
                    'RM${totalExpense.abs().toStringAsFixed(2)}',
                    () => pushPage(const DebtDetailPage()),
                    color: (alarming_limit > 0) ? DANGER_COLOR : RM5_COLOR,
                    infotext: (alarming_limit > 0) ? '(Over spending)' : null,
                    font_color:
                        (alarming_limit > 0) ? WHITE_TEXT_COLOR : TEXT_COLOR,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(),
            flex: 1,
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
               key: TutorialHelper.financialKeys[4 +index],
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
    return Scaffold(
      backgroundColor: HIGHTLIGHT_COLOR,
      appBar: BugAppBar("Financial Page", context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Assets Card
              Center(child: BugPageIndicator(FinancialPage.financialPageController, 3)),
              Expanded(
                flex: 3,
                child: PageView(
                  controller: FinancialPage.financialPageController,
                  physics: ClampingScrollPhysics(),
                  children: [
                    AssetDebtSection(),
                    // Page 1
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
                    // Page 2
                  ],
                ),
              ),

              Expanded(flex: 2, child: QuickActionSection(2))
              // Chart Card
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
            height: ResStyle.height * 0.3,
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
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TransactionGraphPage(
                                currentAsset: currentAsset,
                                transactions: transactions,
                                header: header,
                              )));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
