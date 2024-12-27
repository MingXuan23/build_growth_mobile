import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/financial/financial_bloc.dart';
import 'package:build_growth_mobile/bloc/transaction/transaction_bloc.dart';
import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/models/user_privacy.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
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
  int alternative_asset_id = -1;
  bool transaction_read_only = true;
  bool negative = false;

  List<Asset> asset_list = [];
  List<Debt> debt_list = [];

  TextEditingController transaction_controller =
      TextEditingController(text: "RM 0.00");
  TextEditingController current_value_controller = TextEditingController();
  TextEditingController new_value_controller = TextEditingController();
  TextEditingController desc_controller = TextEditingController();

  final GlobalKey<FormState> assetTransferFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> debtPaymentFormKey = GlobalKey<FormState>();

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
            name: 'Not Selected',
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

    selected_asset_id = widget.asset?.id ?? -1;
    setState(() {});
  }

void continueAddProof() async{
  // Example condition: Check if the user has already rejected adding proof
  bool userRejected = !UserPrivacy.promptTransactionProof; // Replace with actual condition or state management

  if (userRejected) {
    Navigator.of(context).pop();
    return; // Exit if the user previously rejected adding proof
  }

  // Show a dialog to prompt the user to add proof
  await showDialog(
    context: context,
    builder: (BuildContext context) {

      return BugInfoDialog(  
        main_color:RM50_COLOR ,

        title: 'Transaction Proof',
  message: 'Would you like to add proof for this transaction?\n\n'
           '*Tip: You can disable this prompt in the settings if you prefer not to see it again.*',
      actions: [

        BugPrimaryButton(text: 'Yes',
        color: RM50_COLOR, onPressed: () async{
            Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop();
              // Navigate to the transaction history page
              await  Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TransactionHistoryPage()),
              );

              //
        }),
        SizedBox(height: ResStyle.spacing,),
         BugPrimaryButton(text: 'No' ,color: DANGER_COLOR , onPressed: () async{
            Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Exit the page
        })
        
      ]);

    },
  );
}

  void loadPage() async {
    await loadData();
    if (widget.intention == "Debt Transaction") {
      appabar_title = 'Debt Transaction';
      selected_debt_id = widget.debt?.id ?? -1;
      BlocProvider.of<TransactionBloc>(context).add(ShowPayDebtPage());
    } else if (widget.intention == 'Asset Transfer') {
      appabar_title = 'Asset Transfer';
      BlocProvider.of<TransactionBloc>(context).add(ShowAssetTransferPage());
    } else if (widget.intention == 'Asset Transaction') {
      appabar_title = 'Asset Transaction';
      BlocProvider.of<TransactionBloc>(context).add(ShowAssetTransactionPage());
    }
  }

  void updateSelectedAsset(int value) {
    selected_asset_id = value;

    final asset = asset_list.firstWhere((e) => e.id == selected_asset_id);
    current_value_controller.text = FormatterHelper.toDoubleString(asset.value);

    if (widget.debt?.type == 'Dynamic Bills' ||
        widget.debt?.type == 'Expenses') {
      new_value_controller.text = FormatterHelper.toDoubleString(asset.value +
          FormatterHelper.getAmountFromRM(transaction_controller.text));
    } else if (widget.debt != null) {
      transaction_controller.text =
          FormatterHelper.toDoubleString(-widget.debt!.monthly_payment);
      new_value_controller.text = FormatterHelper.toDoubleString(
          asset.value - widget.debt!.monthly_payment);
    }
  }

  void updateAlternativeAsset(int value) {
    alternative_asset_id = value;
    setState(() {});
  }

  void updateDebtPaymentTransaction() async {
    try {
      if (!debtPaymentFormKey.currentState!.validate()) {
        return;
      }
      final transactionAmount =
          FormatterHelper.getAmountFromRM(transaction_controller.text);

      var asset = asset_list.firstWhere((e) => e.id == selected_asset_id);
      var debt = debt_list.firstWhere((e) => e.id == selected_debt_id);

      final transaction = Transaction(
        asset.user_code ?? debt.user_code ?? '',
        amount: transactionAmount,
        desc: desc_controller.text,
        asset_id: selected_asset_id == -1 ? null : selected_asset_id,
        debt_id: selected_debt_id == -1 ? null : selected_debt_id,
        created_at: DateTime.now(),
      );

      await Transaction.insertTransaction(transaction);

      if (selected_asset_id != -1) {
        asset.value = asset.value +
            transactionAmount; //because transactionAmount was negative now
        await Asset.updateAsset(asset, t: transaction);
      }

      if (selected_debt_id != -1) {
        debt.last_payment_date = DateTime.now();
        debt.remaining_month = debt.remaining_month - 1;
        await Debt.updateDebt(debt);
      }

      BlocProvider.of<TransactionBloc>(context)
          .add(CompleteTransactionAction());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Error: ${e}', 8));
    }
  }

  void updateAssetTransferTransaction() async {
    try {
      final transactionAmount =
          FormatterHelper.getAmountFromRM(transaction_controller.text);

      if (selected_asset_id == -1 || alternative_asset_id == -1) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return BugInfoDialog(
                  title: 'Warning',
                  main_color: DANGER_COLOR,
                  message: 'You need to select the assets to transfer',
                  actions: [
                    BugPrimaryButton(
                        text: 'Ok',
                        color: TITLE_COLOR,
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ]);
            });

        return;
      }

      if (!assetTransferFormKey.currentState!.validate()) {
        return;
      }

      var from_asset = asset_list.firstWhere((e) => e.id == selected_asset_id);
      var to_asset = asset_list.firstWhere((e) => e.id == alternative_asset_id);

      final from_transaction = Transaction(
        from_asset.user_code,
        amount: -transactionAmount,
        desc: desc_controller.text,
        asset_id: from_asset.id,
        debt_id: null,
        created_at: DateTime.now(),
      );

      final to_transaction = Transaction(
        to_asset.user_code,
        amount: transactionAmount,
        desc: desc_controller.text,
        asset_id: to_asset.id,
        debt_id: null,
        created_at: DateTime.now(),
      );

      await Transaction.insertTransaction(from_transaction);
      await Transaction.insertTransaction(to_transaction);

      from_asset.value = from_asset.value - transactionAmount;
      to_asset.value = to_asset.value + transactionAmount;

      await Asset.updateAsset(
        from_asset,
      );
      await Asset.updateAsset(to_asset);

      BlocProvider.of<TransactionBloc>(context)
          .add(CompleteTransactionAction());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Error: ${e}', 8));
    }
  }

  void implement_RM_format(TextEditingController controller, String value) {
    controller.text = FormatterHelper.toFixed2(value);
    assetTransferFormKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) async {
          if (state is TransactionDebtPageShow) {
            transaction_read_only = widget.debt!.type == 'Recurring Bills' ||
                widget.debt!.type == 'Loans';
            transaction_controller.text =
                FormatterHelper.toDoubleString(-widget.debt!.monthly_payment);
            body = debtPaymentPage(asset_list);
          } else if (state is AssetTransferPageShow) {
            body = AssetTransferPage(
              asset_list: asset_list,
              asset: widget.asset,
            );
          } else if (state is AssetTransactionrPageShow) {
            body = AssetTransactionPage(asset: widget.asset!);
          } else if (state is TransactionCompleted) {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return BugInfoDialog(
                      title: 'Success',
                      main_color: RM50_COLOR,
                      message: 'Transaction Saved Successfully',
                      actions: [
                        BugPrimaryButton(
                            text: 'Ok',
                            color: RM50_COLOR,
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ]);
                });

             continueAddProof();
            
          }

          setState(() {});
        },
        child: Scaffold(
          appBar: BugAppBar(appabar_title, context),
          backgroundColor: HIGHTLIGHT_COLOR,
          body: Padding(
            padding: EdgeInsets.all(ResStyle.spacing),
            child: body,
          ),
        ));
  }

  Widget debtPaymentPage(List<Asset> asset_list) {
    return Form(
      key: debtPaymentFormKey,
      child: Column(
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
                    validator: (value) {
                      if (value == -1 || value == null) {
                        return 'Select The Asset';
                      }
                      return null;
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
                    validator: (value) {
                     
                    },
                  ),
                  SizedBox(height: ResStyle.spacing * 3),
                  BugTextInput(
                    controller: transaction_controller,
                    label: 'Transaction Value',
                    hint: 'Transaction Value',
                    prefixIcon: const Icon(null),
                    readOnly: transaction_read_only,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        value = "RM 0.00";
                      }

                      FormatterHelper.implement_RM_format(
                          transaction_controller, value,
                          negative: true);

                      updateSelectedAsset(selected_asset_id);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'PLease Enter Transaction Value';
                      }

                      var amount = FormatterHelper.getAmountFromRM(
                          transaction_controller.text);
                      if (amount == 0) {
                        return 'The Minimum Amount is RM 0.01';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: ResStyle.spacing),
                  BugTextInput(
                    controller: new_value_controller,
                    label: 'New Asset Value',
                    hint: 'New Asset Value',
                    prefixIcon: const Icon(null),
                    readOnly: true,
                    validator: (value) {
                       if(FormatterHelper.getAmountFromRM(value??'RM 0.00') < 0){
                         return "You have not enough balance. Turn this into a lesson: Build assets and Reduce debts to grow your cash flow.";
                      }
                    },
                  ),
                  SizedBox(height: 2 * ResStyle.spacing),
                  BugTextInput(
                    controller: desc_controller,
                    label: 'Note',
                    hint: 'Note',
                    prefixIcon: const Icon(null),
                    validator: (value) {},
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
      ),
    );
  }

  // Widget assetTransferPage(List<Asset> asset_list) {
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: SingleChildScrollView(
  //           child: Form(
  //             key: assetTransferFormKey,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 (widget.asset != null)
  //                     ? BugHeaderCard('From ${widget.asset!.name}')
  //                     : BugComboBox(
  //                         selected_value: selected_asset_id,
  //                         onChanged: (value) {
  //                           if (value == null) return;
  //                           updateSelectedAsset(value);
  //                         },
  //                         itemlist: asset_list
  //                             .where((e) =>
  //                                 e.id != alternative_asset_id || e.id == -1)
  //                             .map((asset) {
  //                           return DropdownMenuItem<int>(
  //                             value: asset.id,
  //                             child: Text(asset.name),
  //                           );
  //                         }).toList(),
  //                         labelText: 'From Asset',
  //                       ),
  //                 SizedBox(height: ResStyle.spacing),
  //                 BugComboBox(
  //                   selected_value: alternative_asset_id,
  //                   onChanged: (value) {
  //                     if (value == null) return;
  //                     updateAlternativeAsset(value);
  //                   },
  //                   itemlist: asset_list
  //                       .where((e) => e.id != selected_asset_id || e.id == -1)
  //                       .map((asset) {
  //                     return DropdownMenuItem<int>(
  //                       value: asset.id,
  //                       child: Text(asset.name),
  //                     );
  //                   }).toList(),
  //                   labelText: 'To Asset',
  //                 ),
  //                 SizedBox(height: ResStyle.spacing),
  //                 BugTextInput(
  //                   controller: transaction_controller,
  //                   label: 'Transaction Value',
  //                   hint: 'Transaction Value',
  //                   prefixIcon: const Icon(null),
  //                   onChanged: (value) {
  //                     implement_RM_format(transaction_controller, value);
  //                   },
  //                   validator: (value) {
  //                     if (value == null) {
  //                       return 'Enter Transaction Value';
  //                     }
  //                     var asset = asset_list
  //                         .firstWhere((e) => e.id == selected_asset_id);
  //                     var field_value = FormatterHelper.getAmountFromRM(value);

  //                     if (field_value > 0 && field_value <= asset.value) {
  //                       return null;
  //                     }
  //                     return "The minimum value is RM 0.01\n The maximum value is ${FormatterHelper.toDoubleString(asset.value)}";
  //                   },
  //                 ),
  //                 SizedBox(height: ResStyle.spacing),
  //                 BugTextInput(
  //                     controller: desc_controller,
  //                     label: 'Note',
  //                     hint: 'Note',
  //                     prefixIcon: const Icon(null),
  //                     validator: (value) {}),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //       Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Padding(
  //           padding: EdgeInsets.only(bottom: ResStyle.spacing),
  //           child: BugPrimaryButton(
  //             text: 'Update ',
  //             onPressed: updateAssetTransferTransaction,
  //             color: TITLE_COLOR,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Function to update the transaction type (Earn/Spend)
  void updateTransactionType(bool isNegative) {
    negative = isNegative;
    setState(() {});
  }
}

class AssetTransactionPage extends StatefulWidget {
  final Asset asset;

  const AssetTransactionPage({super.key, required this.asset});
  @override
  _AssetTransactionPageState createState() => _AssetTransactionPageState();
}

class _AssetTransactionPageState extends State<AssetTransactionPage> {
  bool negative =
      false; // Track the transaction type (false for Earn, true for Spend)

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController transactionController =
      TextEditingController(text: 'RM 0.00');
  TextEditingController newValueController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool transactionReadOnly = false;

  void updateTransactionType(bool value) {
    setState(() {
      negative = value;
    });

    onChangeTrigger(transactionController.text);
  }

  void saveTransaction() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final transactionAmount =
          FormatterHelper.getAmountFromRM(transactionController.text);

      final transaction = Transaction(
        widget.asset.user_code ?? '',
        amount: transactionAmount,
        desc: descController.text,
        asset_id: widget.asset.id,
        debt_id: null,
        created_at: DateTime.now(),
      );

      await Transaction.insertTransaction(transaction);

      var asset = widget.asset;
      asset.value = asset.value + transactionAmount;
      await Asset.updateAsset(asset, t: transaction);

      BlocProvider.of<TransactionBloc>(context)
          .add(CompleteTransactionAction());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Error: ${e}', 8));
    }
  }

  void onChangeTrigger(String? value) {
    if (value == null || value.isEmpty) {
      value = "RM 0.00";
    }

    FormatterHelper.implement_RM_format(transactionController, value,
        negative: negative);

    var amount =
        FormatterHelper.getAmountFromRM(transactionController.text).abs();

    FormatterHelper.implement_RM_format(
        transactionController, FormatterHelper.toDoubleString(amount),
        negative: negative);

    newValueController.text = FormatterHelper.toDoubleString(
        widget.asset.value +
            FormatterHelper.getAmountFromRM(transactionController.text));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transactionController.text = 'RM 0.00';
    newValueController.text =
        FormatterHelper.toDoubleString(widget.asset.value);
  }

  String getReduceTerm(String assetType) {
    if (assetType == 'Stock') {
      return 'Lose';
    } else {
      return 'Spend';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  BugHeaderCard('Transaction of ${widget.asset.name}'),
                  SizedBox(height: ResStyle.spacing),

                  // Segmented Button for transaction type
                  Container(
                    decoration: BoxDecoration(
                        color: HIGHTLIGHT_COLOR,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PRIMARY_COLOR)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => updateTransactionType(false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: ResStyle.spacing),
                              decoration: BoxDecoration(
                                color:
                                    !negative ? TITLE_COLOR : HIGHTLIGHT_COLOR,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Earn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResStyle.font,
                                  color: !negative
                                      ? HIGHTLIGHT_COLOR
                                      : TITLE_COLOR,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if(widget.asset.type != "Deposit Account")
                        Expanded(
                          child: GestureDetector(
                            onTap: () => updateTransactionType(true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: ResStyle.spacing),
                              decoration: BoxDecoration(
                                color:
                                    negative ? TITLE_COLOR : HIGHTLIGHT_COLOR,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                               getReduceTerm(widget.asset.type),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResStyle.font,
                                  color:
                                      negative ? HIGHTLIGHT_COLOR : TITLE_COLOR,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResStyle.spacing),

                  // Transaction value input
                  BugTextInput(
                    controller: transactionController,
                    label: 'Transaction Value',
                    hint: 'Transaction Value',
                    prefixIcon: const Icon(null),
                    readOnly: transactionReadOnly,
                    onChanged: onChangeTrigger,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Transaction Value';
                      }
                      var amount = FormatterHelper.getAmountFromRM(
                          transactionController.text);
                      if (amount == 0) {
                        return 'The Minimum Amount is RM 0.01';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResStyle.spacing),

                  // New Asset Value input
                  BugTextInput(
                    controller: newValueController,
                    label: 'New Asset Value',
                    hint: 'New Asset Value',
                    prefixIcon: const Icon(null),
                    onChanged: onChangeTrigger,
                    readOnly: true,
                    validator: (value) {
                      if(FormatterHelper.getAmountFromRM(value??"0.00") < 0){
                        return "If an asset is costing you money instead of making you money, it's actually a debt.";
                      }
                    },
                  ),
                  SizedBox(height: 2 * ResStyle.spacing),

                  // Notes input
                  BugTextInput(
                    controller: descController,
                    label: 'Note',
                    hint: 'Note',
                    prefixIcon: const Icon(null),
                    validator: (value) {},
                  ),
                  SizedBox(height: ResStyle.spacing),
                ],
              ),
            ),
          ),

          // Save button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: ResStyle.spacing),
              child: BugPrimaryButton(
                text: 'Save Transaction',
                onPressed: saveTransaction,
                color: TITLE_COLOR,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssetTransferPage extends StatefulWidget {
  final List<Asset> asset_list;
  final Asset? asset;

  AssetTransferPage({Key? key, required this.asset_list, this.asset})
      : super(key: key);

  @override
  _AssetTransferPageState createState() => _AssetTransferPageState();
}

class _AssetTransferPageState extends State<AssetTransferPage> {
  final GlobalKey<FormState> assetTransferFormKey = GlobalKey<FormState>();

  int? selected_asset_id;
  int? alternative_asset_id;
  TextEditingController transaction_controller = TextEditingController(text:'RM 0.00');
  TextEditingController desc_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected_asset_id = widget.asset?.id;
  }

  @override
  void dispose() {
    transaction_controller.dispose();
    desc_controller.dispose();
    super.dispose();
  }

  void updateSelectedAsset(int value) {
    setState(() {
      selected_asset_id = value;
    });
  }

  void updateAlternativeAsset(int value) {
    setState(() {
      alternative_asset_id = value;
    });
  }

  void updateAssetTransferTransaction() async {
    try {
      final transactionAmount =
          FormatterHelper.getAmountFromRM(transaction_controller.text);

      if (selected_asset_id == -1 || alternative_asset_id == -1) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return BugInfoDialog(
                  title: 'Warning',
                  main_color: DANGER_COLOR,
                  message: 'You need to select the assets to transfer',
                  actions: [
                    BugPrimaryButton(
                        text: 'Ok',
                        color: TITLE_COLOR,
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ]);
            });

        return;
      }

      if (!assetTransferFormKey.currentState!.validate()) {
        return;
      }

      var from_asset =
          widget.asset_list.firstWhere((e) => e.id == selected_asset_id);
      var to_asset =
          widget.asset_list.firstWhere((e) => e.id == alternative_asset_id);

      final from_transaction = Transaction(
        from_asset.user_code,
        amount: -transactionAmount,
        desc: desc_controller.text,
        asset_id: from_asset.id,
        debt_id: null,
        created_at: DateTime.now(),
        transaction_type: 2
      );

      final to_transaction = Transaction(
        to_asset.user_code,
        amount: transactionAmount,
        desc: desc_controller.text,
        asset_id: to_asset.id,
        debt_id: null,
        created_at: DateTime.now(),
        transaction_type: 2
      );

      await Transaction.insertTransaction(from_transaction);
      await Transaction.insertTransaction(to_transaction);

      from_asset.value = from_asset.value - transactionAmount;
      to_asset.value = to_asset.value + transactionAmount;

      await Asset.updateAsset(from_asset);
      await Asset.updateAsset(to_asset);

      BlocProvider.of<TransactionBloc>(context)
          .add(CompleteTransactionAction());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Error: ${e}', 8));
    }
  }

  void implement_RM_format(TextEditingController controller, String value) {
    controller.text = FormatterHelper.toFixed2(value);
    assetTransferFormKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: assetTransferFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.asset != null)
                      ? BugHeaderCard('From ${widget.asset!.name}')
                      : BugComboBox(
                          selected_value: selected_asset_id ?? -1,
                          onChanged: (value) {
                            if (value == null) return;
                            updateSelectedAsset(value);
                          },
                          itemlist: widget.asset_list
                              .where((e) =>
                                  e.id != alternative_asset_id || e.id == -1)
                              .map((asset) {
                            return DropdownMenuItem<int>(
                              value: asset.id,
                              child: Text(asset.name),
                            );
                          }).toList(),
                          labelText: 'From Asset',
                        ),
                  SizedBox(height: ResStyle.spacing),
                  BugComboBox(
                    selected_value: alternative_asset_id ?? -1,
                    onChanged: (value) {
                      if (value == null) return;
                      updateAlternativeAsset(value);
                    },
                    itemlist: widget.asset_list
                        .where((e) => e.id != selected_asset_id || e.id == -1)
                        .map((asset) {
                      return DropdownMenuItem<int>(
                        value: asset.id,
                        child: Text(asset.name),
                      );
                    }).toList(),
                    labelText: 'To Asset',
                  ),
                  SizedBox(height: ResStyle.spacing),
                  BugTextInput(
                    controller: transaction_controller,
                    label: 'Transaction Value',
                    hint: 'Transaction Value',
                    prefixIcon: const Icon(null),
                    onChanged: (value) {
                      implement_RM_format(transaction_controller, value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Enter Transaction Value';
                      }
                      var asset = widget.asset_list
                          .firstWhere((e) => e.id == selected_asset_id);
                      var fieldValue = FormatterHelper.getAmountFromRM(value);

                      if (fieldValue > 0 && fieldValue <= asset.value) {
                        return null;
                      }
                      return "The minimum value is RM 0.01\n The maximum value is ${FormatterHelper.toDoubleString(asset.value)}";
                    },
                  ),
                  SizedBox(height: ResStyle.spacing),
                  BugTextInput(
                    controller: desc_controller,
                    label: 'Note',
                    hint: 'Note',
                    prefixIcon: const Icon(null),
                    validator: (value) {
                      // Your validation logic here
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: ResStyle.spacing),
            child: BugPrimaryButton(
              text: 'Update',
              onPressed: updateAssetTransferTransaction,
              color: TITLE_COLOR,
            ),
          ),
        ),
      ],
    );
  }
}
