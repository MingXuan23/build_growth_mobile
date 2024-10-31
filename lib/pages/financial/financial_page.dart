import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/pages/financial/asset_detail_page.dart';
import 'package:build_growth_mobile/pages/financial/debt_detail_page.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/card.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          }

          setState(() {});
        },
        child: body());
  }

  Widget body() {
    return Scaffold(
      backgroundColor: HIGHTLIGHT_COLOR,
      appBar: BugAppBar("Financial Page"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Assets Card
            
                AssetCard('Total Assets', 'RM${totalAssets.toStringAsFixed(2)}',
                    () => pushPage(const AssetDetailPage())),
            
                SizedBox(height: ResStyle.spacing),
            
                // Total Debts Card
            
                AssetCard(
                    'Total Debt/Bills',
                    'RM${totalDebts.toStringAsFixed(2)}',
                    () => pushPage(const DebtDetailPage()),
                    color: (totalDebts == 0) ? RM5_COLOR : TITLE_COLOR,
                    font_color:
                        (totalDebts == 0) ? TEXT_COLOR:WHITE_TEXT_COLOR  ),
            
                //GeneralCard('\$${totalDebts.toStringAsFixed(2)}',),
            
                SizedBox(height: ResStyle.spacing),
            
                // Chart Card
                _buildLineChartCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 2.5),
                const FlSpot(2, 3.5),
                const FlSpot(3, 3.2),
                const FlSpot(4, 4),
                const FlSpot(5, 3.8),
                const FlSpot(6, 4.5),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
