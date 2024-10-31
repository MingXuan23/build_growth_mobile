import 'package:build_growth_mobile/pages/financial/transaction_page.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
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

  @override
  void initState() {
    super.initState();
    loadDebts();
  }

  Future<void> loadDebts() async {
    // Replace with a function to load all debts
    debts = await Debt.getDebtList();
    setState(() {});
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

          if(debt.remaining_month >0 && !paid)
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
              showDeleteConfirmationDialog(
                  debt); // Show confirmation dialog for deletion
            },
            child:
                const Text('Delete Debt', style: TextStyle(color: Colors.red)),
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

  void showEditDebtDetailsDialog(Debt debt) {
    final TextEditingController nameController =
        TextEditingController(text: debt.name);
    final TextEditingController descController =
        TextEditingController(text: debt.desc);

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

  void navigateToTransactionPage(Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(debt: debt, type: "Debt"),
      ),
    ).then((_) =>
        loadDebts()); // Refresh debts when returning from transaction page
  }

  Widget DebtDetailCard(Debt debt) {
    var paid = FormatterHelper.isSameMonthYear(debt.last_payment_date);
    return GestureDetector(
      onTap: () => showActionSheet(debt),
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: paid ? Colors.green[100] : Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main debt details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (debt.desc!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        debt.desc!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '\$${debt.monthly_payment.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Check icon and date if paid
              if (paid) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatterHelper.dateFormat(debt.last_payment_date!),
                    
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddDebtDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: debts.map((debt) => DebtDetailCard(debt)).toList(),
        ),
      ),
    );
  }

  void showAddDebtDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController monthlyPaymentController =
        TextEditingController();

    int? remainingMonths; // This will hold the user-selected remaining months
    String? selectedType; // This will hold the user-selected debt type

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Debt'),
          content: SingleChildScrollView(
            // Enable scrolling
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Debt Name'),
                    ),
                    TextField(
                      controller: descController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: monthlyPaymentController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Monthly Payment'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: selectedType,
                          hint: const Text('Select Debt Type'),
                          items: const [
                            DropdownMenuItem(
                                value: 'Repeated', child: Text('Repeated')),
                            DropdownMenuItem(
                                value: 'One Time', child: Text('One Time')),
                            DropdownMenuItem(
                                value: 'Period', child: Text('Period')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                              // Reset remaining months based on selected type
                              if (value == 'Repeated') {
                                remainingMonths = -1;
                              } else if (value == 'One Time') {
                                remainingMonths = 1;
                              } else {
                                remainingMonths =
                                    null; // For Period, we will prompt the user for input
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (selectedType == 'Period') ...[
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Remaining Months'),
                        onChanged: (value) {
                          remainingMonths = int.tryParse(value);
                        },
                      ),
                    ],
                  ],
                );
              },
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
                    selectedType != null &&
                    remainingMonths != null) {
                  Debt newDebt = Debt(
                    'user_code', // Replace with actual user code if applicable
                    name: nameController.text,
                    desc: descController.text,
                    type: selectedType!,
                    monthly_payment:
                        double.tryParse(monthlyPaymentController.text) ?? 0.0,
                    remaining_month: remainingMonths!,
                    total_month: 0, // Adjust this as needed
                    status: true,
                  );
                  await Debt.insertDebt(newDebt); // Insert debt into database
                  await loadDebts(); // Refresh the debt list
                  Navigator.of(context).pop();
                } else {
                  // Show an error message or handle validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill in all fields correctly.')),
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

  void showDeleteConfirmationDialog(Debt debt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the debt "${debt.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(); // Dismiss the confirmation dialog before deleting
                var success = await Debt.deleteDebt(
                    debt.id!, false); // Assume you have a deleteDebt method
                if (success > 0) {
                  await loadDebts(); // Refresh the debt list
                  Navigator.of(context).pop(); // Dismiss the details dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debt deleted successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete the debt.')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
