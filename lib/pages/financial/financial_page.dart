import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/pages/financial/TransactionPage2.dart';
import 'package:build_growth_mobile/pages/financial/asset_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/debt_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({Key? key}) : super(key: key);

  @override
  _FinancialPageState createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  // You can add state variables here
  double totalAssets = 0; // Example variable
  double totalDebts = 0; // Example variable
  List<Transaction> transaction_history = [];
  PageController _pageController = PageController(viewportFraction: 1.0);
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
        }

        setState(() {});
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (MediaQuery.of(context).size.height >
              MediaQuery.of(context).size.width) {
            return vertical_body();
          } else {
            return horizontal_body();
          }
        },
      ),
    );
  }

  Widget TransactionGraphSection() {
    List<FlSpot> spots = transaction_history
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.amount))
        .toList();

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
                  'Cash Flow',
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
            height: ResStyle.height * 0.3,
            padding: EdgeInsets.symmetric(
                vertical: ResStyle.spacing * 3,
                horizontal: ResStyle.spacing * 1.5),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
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
        ],
      ),
    );
  }

  Widget AssetDebtSection() {
    return Padding(
      padding: EdgeInsets.all(ResStyle.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Assets Card
          AssetCard(
            'Total Assets',
            'RM${totalAssets.toStringAsFixed(2)}',
            () => pushPage(const AssetDetailPage()),
          ),
          SizedBox(height: ResStyle.spacing),
          // Total Debts Card
          AssetCard(
            'Total Debt/Bills',
            'RM${totalDebts.toStringAsFixed(2)}',
            () => pushPage(const DebtDetailPage()),
            color: (totalDebts == 0) ? RM5_COLOR : TITLE_COLOR,
            font_color: (totalDebts == 0) ? TEXT_COLOR : WHITE_TEXT_COLOR,
          ),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AssetDebtSection(), // Page 1
                      TransactionGraphSection(),
                    ],
                  ),
                ),
              ),

              Expanded(child: QuickActionSection(1))
              // Chart Card
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
              Center(child: BugPageIndicator(_pageController, 2)),
              Expanded(
                flex: 3,
                child: PageView(
                  controller: _pageController,
                  physics: ClampingScrollPhysics(),
                  children: [
                    AssetDebtSection(),
                    // Page 1
                    TransactionGraphSection(), // Page 2
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
