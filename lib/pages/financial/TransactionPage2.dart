import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/bloc/transaction/transaction_bloc.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_text_input.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionPage2 extends StatefulWidget {
  const TransactionPage2(
      {super.key, required this.intention, this.asset, this.debt});

  final String intention;
  final Asset? asset;
  final Debt? debt;

  @override
  State<TransactionPage2> createState() => _TransactionPage2State();
}

class _TransactionPage2State extends State<TransactionPage2> {
  Widget body = Container();
  String appabar_title = '';
  int selected_asset_id = -1;
  int selected_debt_id = -1;

  List<Asset> asset_list = [];
  List<Debt> debt_list = [];

  TextEditingController transaction_controller = TextEditingController();
  TextEditingController current_value_controller = TextEditingController();
  TextEditingController new_value_controller = TextEditingController();
  TextEditingController desc_controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    loadPage();
  }

  Future<void> loadData() async {
    asset_list = await Asset.getAssetList();
    asset_list.insert(
        0,
        Asset('',
            id: -1,
            name: 'From Asset',
            value: 0,
            desc: '',
            type: '',
            status: false));
    debt_list = await Debt.getDebtList();
    debt_list.insert(
        0,
        Debt('',
            id: -1,
            name: 'Other Expense',
            monthly_payment: 0,
            remaining_month: -1,
            total_month: -1,
            desc: '',
            type: 'Dynamic',
            status: false));
    body = body;
    setState(() {});
  }

  void loadPage() async {
    await loadData();
    if (widget.intention == "Debt Transaction") {
      appabar_title = 'Settle Your Expense/Debt';
      BlocProvider.of<TransactionBloc>(context).add(ShowPayDebtPage());
    }
  }

  void updateSelectedAsset(int value) {
    selected_asset_id = value;

    final asset = asset_list.firstWhere((e) => e.id == selected_asset_id);
    current_value_controller.text = FormatterHelper.toDoubleString(asset.value);

    if(widget.debt != null){
      transaction_controller.text = FormatterHelper.toDoubleString(-widget.debt!.monthly_payment);
      new_value_controller.text = FormatterHelper.toDoubleString(asset.value - widget.debt!.monthly_payment);
    }

    
  }

  void updateDebtPaymentTransaction() async{
 try {
      final transactionAmount =
          FormatterHelper.getAmountFromRM(transaction_controller.text);

      final asset = asset_list.firstWhere((e) => e.id == selected_asset_id);
      final debt = debt_list.firstWhere((e) => e.id == selected_debt_id);

      final transaction = Transaction(
        asset.user_code ?? debt.user_code ?? '',
        amount: transactionAmount,
        desc: desc_controller.text,
        asset_id: selected_asset_id == -1 ? null : selected_asset_id,
        debt_id: selected_debt_id == -1 ? null : selected_debt_id,
        created_at: DateTime.now(),
      );

      await Transaction.insertTransaction(transaction);
      
     
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Error: ${e}', 8));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) async {
          if (state is TransactionDebtPage) {
            body = debtPaymentPage(asset_list);
          }

          setState(() {});
        },
        child: Scaffold(
          appBar: BugAppBar(appabar_title),
          body: Padding(
            padding: EdgeInsets.all(ResStyle.spacing),
            child: body,
          ),
        ));
  }

 Widget debtPaymentPage(List<Asset> asset_list) {
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BugHeaderCard('Transaction of ${widget.debt!.name}'),
              BugComboBox(
                selected_value: selected_asset_id,
                onChanged: (value) {
                  if (value == null) return;
                  updateSelectedAsset(value);
                },
                itemlist: asset_list.map((asset) {
                  return DropdownMenuItem<int>(
                    value: asset.id,
                    child: Text(asset.name),
                  );
                }).toList(),
                labelText: 'From Asset',
              ),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                controller: current_value_controller,
                label: 'Current Value',
                hint: 'Current Value',
                prefixIcon: const Icon(null),
                readOnly: true,
              ),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                controller: transaction_controller,
                label: 'Transaction Value',
                hint: 'Transaction Value',
                prefixIcon: const Icon(null),
                readOnly: true,
              ),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                controller: new_value_controller,
                label: 'New Asset Value',
                hint: 'New Asset Value',
                prefixIcon: const Icon(null),
                readOnly: true,
              ),
              SizedBox(height: 2 * ResStyle.spacing),
              BugTextInput(
                controller: desc_controller,
                label: 'Note',
                hint: 'Note',
                prefixIcon: const Icon(null),
                
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: ResStyle.spacing),
          child: BugPrimaryButton(
            text: 'Save Transaction',
            onPressed: updateDebtPaymentTransaction,
            color: TITLE_COLOR,
            
          ),
        ),
      ),
    ],
  );
}

}
