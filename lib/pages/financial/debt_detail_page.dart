import 'dart:math';

import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:build_growth_mobile/pages/financial/TransactionPage2.dart';
import 'package:build_growth_mobile/pages/financial/transaction_history_page.dart';
import 'package:build_growth_mobile/pages/financial/transaction_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/services/tutorial_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_input.dart';
import 'package:build_growth_mobile/widget/bug_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:build_growth_mobile/models/debt.dart';

class DebtDetailPage extends StatefulWidget {
  const DebtDetailPage({super.key});

  static final page_controller = PageController();
  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  List<Debt> debts = [];
  bool _isExpanded = false;

  bool isLoading = true;
  final List<String> debtTypes = [
    'Expenses',
    'Loans',
    'Recurring Bills',
    'Dynamic Bills',
  ];

  final List<String> debtDesc = [
    'Categorize and track daily expenses.',
    'Fixed monthly payment over a set period.',
    'Fixed amount paid monthly.',
    'Variable amount paid monthly.',
  ];

  @override
  void initState() {
    super.initState();
    loadDebts();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //page_controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HIGHTLIGHT_COLOR,
        appBar: BugAppBar('Your Debts', context),
        body: Padding(
            padding: EdgeInsets.all(ResStyle.spacing),
            child: isLoading
                ? BugLoading()
                : debts.isNotEmpty
                    ? Column(
                        children: [
                          BugPageIndicator(DebtDetailPage.page_controller, 2),
                          Expanded(
                            child: PageView(
                              controller: DebtDetailPage.page_controller,
                              children: [
                                _buildDebtList(),
                                _buildDebtTutorialPage(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildDebtTutorialPage()));
  }

  Future<void> loadDebts() async {
    debts = await Debt.getDebtList();

    isLoading = false;

    //await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  Widget _buildDebtList() {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  if (debts[index].type == 'Expenses' ) {
                    return ExpenseDetailCard(
                      debts[index],
                      () => showActionSheet(debts[index]),
                    );
                  } else {
                    return DebtDetailCard(
                        debts[index], () => showActionSheet(debts[index]));
                  }
                })),
        Padding(
          padding: EdgeInsets.all(ResStyle.spacing),
          child: BugPrimaryButton(
              text: 'Add More Debts >>',
              onPressed: _goToNextPage,
              color: TITLE_COLOR),
        ),
      ],
    );
  }

  void _goToNextPage() async {
    // await page_controller.nextPage(
    //     duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);

    DebtDetailPage.page_controller.nextPage(
      duration: Duration(milliseconds: 700),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget _buildDebtTutorialPage() {
    return Padding(
      padding: EdgeInsets.all(ResStyle.spacing),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: ResStyle.spacing,
                crossAxisSpacing: ResStyle.spacing,
                childAspectRatio: 0.7,
              ),
              itemCount: debtTypes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  key: TutorialHelper.debtKeys[index],
                  onTap: () => showAddDebtModal(debtTypes[index]),
                  child: _buildDebtCard(context, index),
                );
              },
            ),
          ),
          BugInfoCard(
              'Your financial data will never be stored in the server side. Any processing of your sensitive financial data in the server, with your permission, will be securely handled. Thank you for your trust.'),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, int index) {
    // Description for each debt type
    String description = debtDesc[index];
    String debtType = debtTypes[index];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TITLE_COLOR,
            TITLE_COLOR.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 3,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(ResStyle.spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Debt type text, bold and centered
          Text(
            debtType,
            style: TextStyle(
              fontSize: ResStyle.body_font,
              fontWeight: FontWeight.bold,
              color: HIGHTLIGHT_COLOR,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResStyle.spacing / 2),
          // Description text, non-bold and centered
          Text(
            description,
            style: TextStyle(
              fontSize: ResStyle.small_font,
              fontWeight: FontWeight.normal,
              color: HIGHTLIGHT_COLOR,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddDebtButton() {
    return SizedBox(
      width: ResStyle.spacing * 5,
      height: ResStyle.spacing * 5,
      child: FloatingActionButton(
        backgroundColor: TITLE_COLOR,
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (!_isExpanded) {
              DebtDetailPage.page_controller.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        },
        child: Icon(
          _isExpanded ? Icons.close : Icons.add,
          size: ResStyle.header_font,
          color: HIGHTLIGHT_COLOR,
        ),
      ),
    );
  }

  void _selectOption(String option) {
    showAddDebtModal(option);
  }

  void navigateToTransactionPage(Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage2(
            debt: debt,
            intention:
                "Debt Transaction"), //TransactionPage(debt: debt, type: "Debt"),
      ),
    ).then((_) => loadDebts());
  }

  void showActionSheet(Debt debt) {
    var paid = FormatterHelper.isSameMonthYear(debt.last_payment_date);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          debt.name,
          style: TextStyle(color: TITLE_COLOR), // Title color
        ),
        message: Text(
          debt.type == 'Expenses'
              ? 'RM${debt.month_total_expense.abs().toStringAsFixed(2)}'
              : 'RM${debt.monthly_payment.toStringAsFixed(2)}',
          style: TextStyle(
              color: TITLE_COLOR, fontSize: ResStyle.font), // Message color
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showEditDebtDetailsModal(debt);
            },
            child: Center(
              child: Text(
                'Edit Debt Details',
                style: TextStyle(
                    color: TITLE_COLOR, fontSize: ResStyle.font), // Text color
              ),
            ),
          ),
          if ((debt.remaining_month != 0 && !paid) || debt.type == 'Expenses')
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                navigateToTransactionPage(debt);
              },
              child: Center(
                child: Text(
                  'Make Transaction',
                  style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font),
                ),
              ),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransactionHistoryPage(
                        debtId: debt,
                      )));
            },
            child: Text(
              'View Transactions',
              style: TextStyle(color: TITLE_COLOR, fontSize: ResStyle.font),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showDeleteConfirmationDialog(debt);
            },
            child: Center(
              child: Text(
                'Delete Debt',
                style: TextStyle(
                    color: DANGER_COLOR,
                    fontSize: ResStyle.font), // Danger color for delete action
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: DANGER_COLOR,
                  fontSize: ResStyle.font), // Title color for cancel button
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(Debt debt) {
    showDialog(
      context: context,
      builder: (context) {
        return BugInfoDialog(
          main_color: DANGER_COLOR,
          title: 'Delete Confirmation',
          message: 'Are you sure you want to delete "${debt.name}"?',
          actions: [
            BugPrimaryButton(
              color: DANGER_COLOR,
              onPressed: () async {
                await Debt.deleteDebt(debt.id!, false);
                await loadDebts();
                Navigator.of(context).pop();
              },
              text: 'Delete',
            ),
            SizedBox(
              height: ResStyle.spacing,
            ),
            BugPrimaryButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: PRIMARY_COLOR,
              text: 'Cancel',
            ),
          ],
        );
      },
    );
  }

  void showEditDebtDetailsModal(Debt debt) {
    final TextEditingController nameController =
        TextEditingController(text: debt.name);
    final TextEditingController descController =
        TextEditingController(text: debt.desc);
    final TextEditingController limitController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    if (debt.alarming_limit > 0 &&
        (debt.type == 'Expenses' || debt.type == 'Dynamic Bills')) {
      FormatterHelper.implement_RM_format(
          limitController, debt.alarming_limit.toStringAsFixed(2));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Form(
          key: _formKey,
          child: BugBottomModal(
            context: context,
            header: 'Edit Debt Details',
            widgets: [
              BugTextInput(
                controller: nameController,
                label: 'Debt Name',
                hint: 'Enter Debt Name',
                prefixIcon: Icon(Icons.monetization_on),
              ),
              SizedBox(height: ResStyle.spacing),
              if (debt.type == 'Expenses' || debt.type == 'Dynamic Bills')
                BugTextInput(
                    controller: limitController,
                    label: 'Alarming Limit',
                    hint: 'No Limit Now',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.attach_money),
                    onChanged: (value) {
                      FormatterHelper.implement_RM_format(
                          limitController, value);
                    },
                    validator: (p0) {
                      if (FormatterHelper.getAmountFromRM(p0 ?? 'RM 0.00') <=
                          0) {
                        return 'The Alarming Limit should not be zero';
                      }
                    },
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear_rounded),
                        onPressed: () {
                          limitController.text = '';
                          debt.alarming_limit = -1;
                        })),
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                  controller: descController,
                  label: 'Description',
                  hint: 'Enter Description',
                  prefixIcon: Icon(Icons.note_alt_sharp),
                  validator: (value) {
                    return null;
                  }),
              SizedBox(height: ResStyle.spacing * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BugPrimaryButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: DANGER_COLOR,
                        text: 'Cancel',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BugPrimaryButton(
                        color: RM50_COLOR,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            debt.name = nameController.text;
                            debt.desc = descController.text;
                            if (limitController.text.isNotEmpty) {
                              debt.alarming_limit =
                                  FormatterHelper.getAmountFromRM(
                                      limitController.text);
                            }
                            await Debt.updateDebt(debt);
                            await loadDebts();
                            Navigator.of(context).pop();
                          }
                        },
                        text: 'Update',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddDebtModal(String selectedType) {
    final TextEditingController nameController =
        TextEditingController(text: 'New $selectedType');
    final TextEditingController descController = TextEditingController();
    final TextEditingController monthlyPaymentController =
        TextEditingController();

    final TextEditingController remainingMonthController =
        TextEditingController();
    final TextEditingController AlarmingLimitController =
        TextEditingController();

    double? alarming_limit;

    int? remainingMonths;
    String warning = '';
    // Set default remaining months based on type
    if (selectedType != 'Loans') {
      remainingMonths = -1;
    }

    final _formKey = GlobalKey<FormState>();
    if (selectedType == 'Recurring Bills' || selectedType == 'Loans') {
      monthlyPaymentController.text = 'RM 0.01';
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Form(
          key: _formKey,
          child: BugBottomModal(
            context: context,
            header: 'Add New $selectedType',
            widgets: [
              BugTextInput(
                controller: nameController,
                label: 'Debt Name',
                hint: 'Enter Debt Name',
                prefixIcon: Icon(Icons.monetization_on),
              ),
              SizedBox(height: ResStyle.spacing),
              if (selectedType == 'Recurring Bills' ||
                  selectedType == 'Loans') ...[
                BugTextInput(
                  controller: monthlyPaymentController,
                  label: 'Monthly Payment',
                  hint: 'Enter Monthly Payment',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.attach_money),
                  onChanged: (value) {
                    FormatterHelper.implement_RM_format(
                        monthlyPaymentController, value);
                  },
                  validator: (p0) {
                    if (FormatterHelper.getAmountFromRM(p0 ?? 'RM 0.00') <= 0) {
                      return 'The Monthly Payment should not be zero';
                    }
                  },
                ),
              ] else ...[
                BugTextInput(
                    controller: AlarmingLimitController,
                    label: 'Alarming Limit',
                    hint: 'No Limit Now',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.attach_money),
                    onChanged: (value) {
                      FormatterHelper.implement_RM_format(
                          AlarmingLimitController, value);
                      alarming_limit = FormatterHelper.getAmountFromRM(
                          AlarmingLimitController.text);
                    },
                    validator: (p0) {
                      if (p0?.isNotEmpty ?? false) {
                        if (FormatterHelper.getAmountFromRM(p0!) <= 0) {
                          return 'The Alarming Limit should not be zero';
                        }
                      }
                    },
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear_rounded),
                        onPressed: () {
                          AlarmingLimitController.text = '';
                          alarming_limit = -1;
                        })),
              ],
              SizedBox(height: ResStyle.spacing),
              BugTextInput(
                  controller: descController,
                  label: 'Description',
                  hint: 'Enter Description',
                  prefixIcon: Icon(Icons.note_alt_sharp),
                  validator: (value) {
                    return null;
                  }),
              SizedBox(height: ResStyle.spacing),
              if (selectedType == 'Loans')
                BugTextInput(
                  controller: remainingMonthController,
                  label: 'Remaining Month',
                  hint: 'Enter Remaining Month',
                  prefixIcon: Icon(Icons.calendar_month),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      remainingMonthController.text = "";
                      return;
                    }
                    var m = int.tryParse(value);
                    if ((m ?? 0) <= 0) {
                      m = 1;
                    }

                    m = min(m ?? 1, 9999);
                    remainingMonths = m;
                    remainingMonthController.text = remainingMonths.toString();
                  },
                ),
              SizedBox(height: ResStyle.spacing * 2),
              Text(
                warning,
                style: TextStyle(
                    fontSize: ResStyle.small_font, color: DANGER_COLOR),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: ResStyle.spacing),
                      child: BugPrimaryButton(
                        onPressed: () => Navigator.of(context).pop(),
                        color: DANGER_COLOR,
                        text: 'Cancel',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: ResStyle.spacing),
                      child: BugPrimaryButton(
                        color: RM50_COLOR,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Debt newDebt = Debt(
                              UserToken.user_code,
                              name: nameController.text,
                              desc: descController.text,
                              type: selectedType,
                              monthly_payment: FormatterHelper.getAmountFromRM(
                                  monthlyPaymentController.text),
                              remaining_month: remainingMonths!,
                              total_month: remainingMonths!,
                              alarming_limit: alarming_limit ?? -1,
                              status: true,
                            );
                            await Debt.insertDebt(newDebt);
                            await loadDebts();
                            Navigator.of(context).pop();

                            if (DebtDetailPage.page_controller.hasClients) {
                              DebtDetailPage.page_controller.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.fastOutSlowIn,
                              );
                            }
                          } else {}
                        },
                        text: 'Add',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
