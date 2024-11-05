import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/pages/financial/TransactionPage2.dart';
import 'package:build_growth_mobile/pages/financial/transaction_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:build_growth_mobile/models/debt.dart';

class DebtDetailPage extends StatefulWidget {
  const DebtDetailPage({super.key});

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  List<Debt> debts = [];
  bool _isExpanded = false;
  final ScrollController scrollController = ScrollController();
  final List<String> debtTypes = [
    'Repeated',
    'One Time',
    'Period'
  ];

@override
void initState() {
  super.initState();
  loadDebts();
  
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BugAppBar('Your Debts'),
      body: Column(
        children: [
          _buildDebtTypeList(),
          Expanded(child: _buildDebtList()),
          
        ],
      ),
    
    );
  }

 Future<void> loadDebts() async {
    debts = await Debt.getDebtList();
    setState(() {});
  }

  Widget _buildDebtList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: debts.isNotEmpty 
        ? ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) => DebtDetailCard(debts[index], ()=>showActionSheet(debts[index])),
          )
        : const Center(child: Text('No debts available')),
    );
  }

 
  Widget _buildDebtTypeList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(debtTypes.length, (index) {
          return GestureDetector(
            onTap: () => _selectOption(debtTypes[index]),
            child: Container(
              margin: EdgeInsets.all(ResStyle.spacing),
              padding: EdgeInsets.symmetric(
                vertical: ResStyle.spacing,
                horizontal: ResStyle.spacing,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TITLE_COLOR,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: HIGHTLIGHT_COLOR),
                  SizedBox(width: ResStyle.spacing / 2),
                  Text(
                    debtTypes[index],
                    style: TextStyle(
                      fontSize: ResStyle.font,
                      color: HIGHTLIGHT_COLOR,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
              scrollController.animateTo(
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
    showAddDebtDialog(option);
  }

   void navigateToTransactionPage(Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  TransactionPage2(debt: debt, intention: "Debt Transaction"), //TransactionPage(debt: debt, type: "Debt"),
      ),
    ).then((_) => loadDebts());
  }

void showActionSheet(Debt debt) {
    var paid = FormatterHelper.isSameMonthYear(debt.last_payment_date);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(debt.name),
        message: Text('\$${debt.monthly_payment.toStringAsFixed(2)}'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showEditDebtDetailsDialog(debt);
            },
            child: const Text('Edit Debt Details'),
          ),
          if ( debt.remaining_month != 0 && !paid) 
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                navigateToTransactionPage(debt);
              },
              child: const Text('Make Transaction'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showDeleteConfirmationDialog(debt);
            },
            child: const Text('Delete Debt', style: TextStyle(color: Colors.red)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

   void showDeleteConfirmationDialog(Debt debt) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Debt'),
          content: const Text('Are you sure you want to delete this debt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Debt.deleteDebt(debt.id!,false);
                await loadDebts();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void showEditDebtDetailsDialog(Debt debt) {
    final TextEditingController nameController = TextEditingController(text: debt.name);
    final TextEditingController descController = TextEditingController(text: debt.desc);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Debt Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Debt Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                debt.name = nameController.text;
                debt.desc = descController.text;
                await Debt.updateDebt(debt);
                await loadDebts();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  void showAddDebtDialog(String selectedType) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController monthlyPaymentController = TextEditingController();
    int? remainingMonths;

    // Set default remaining months based on type
    if (selectedType == 'Repeated') {
      remainingMonths = -1;
    } else if (selectedType == 'One Time') {
      remainingMonths = 1;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Debt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Debt Name'),
                ),
                TextField(
                  controller: monthlyPaymentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monthly Payment'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: debtTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                      if (value == 'Repeated') {
                        remainingMonths = -1;
                      } else if (value == 'One Time') {
                        remainingMonths = 1;
                      } else {
                        remainingMonths = null;
                      }
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Debt Type'),
                ),
                if (selectedType == 'Period')
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Remaining Months'),
                    onChanged: (value) {
                      remainingMonths = int.tryParse(value);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    monthlyPaymentController.text.isNotEmpty &&
                    remainingMonths != null) {
                  Debt newDebt = Debt(
                    'user_code',
                    name: nameController.text,
                    desc: descController.text,
                    type: selectedType,
                    monthly_payment: double.tryParse(monthlyPaymentController.text) ?? 0.0,
                    remaining_month: remainingMonths!,
                    total_month: remainingMonths!,
                    status: true,
                  );
                  await Debt.insertDebt(newDebt);
                  await loadDebts();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}