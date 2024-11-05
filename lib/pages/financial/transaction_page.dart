import 'package:build_growth_mobile/models/asset.dart';
import 'package:build_growth_mobile/models/debt.dart';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/services/formatter_helper.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  final Asset? asset;
  final Debt? debt;
  final String type;

  const TransactionPage({
    Key? key,
    this.asset,
    this.debt,
    required this.type,
  }) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _currentValueController = TextEditingController();
  final TextEditingController _transactionValueController =
      TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int _selectedAssetId = -1;
  int _selectedDebtId = -1;
  List<Asset> _assetList = [];
  List<Debt> _debtList = [];
  bool _isLoading = true;
  bool _isTransactionValueLocked = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadData();
      _initializeSelections();
      _updateControllerValues();
    } catch (e) {
      _showError('Error initializing data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    _assetList = await Asset.getAssetList();
    _debtList = await Debt.getDebtList();

    _assetList.insert(
        0,
        Asset(null,
            name: "Not Specified",
            value: 0,
            desc: "",
            type: "",
            status: false,
            id: -1));
    _debtList.insert(
        0,
        Debt(null,
            name: "Not Specified",
            desc: "",
            type: "",
            status: false,
            monthly_payment: 0,
            remaining_month: 0,
            total_month: 0,
            id: -1));
  }

  void _initializeSelections() {
    setState(() {
      if (widget.type == 'Asset') {
        _selectedAssetId = widget.asset?.id ?? -1;
        _selectedDebtId = -1;
      } else {
        _selectedAssetId = -1;
        _selectedDebtId = widget.debt?.id ?? -1;
      }
    });
  }

  void _updateControllerValues() {
    final asset_value = _getCurrentValue();

    if (_selectedDebtId != -1 && _selectedDebtId != 0) {
      final debt = _debtList.firstWhere((e) => e.id == _selectedDebtId);
      _currentValueController.text = FormatterHelper.toFixed2(
          (asset_value - debt.monthly_payment).toStringAsFixed(2));
      _transactionValueController.text =
          FormatterHelper.toFixed2((-debt.monthly_payment).toStringAsFixed(2));

      _isTransactionValueLocked = true;
    } else {
      _currentValueController.text =
          FormatterHelper.toFixed2((asset_value).toStringAsFixed(2));
      _transactionValueController.text = '0.00';
      _isTransactionValueLocked = false;
    }
  }

  double _getCurrentValue() {
    final asset = _assetList.firstWhere((e) => e.id == _selectedAssetId);
    return asset.value;
  }

  double _getDebtValue() {
    final debt = _debtList.firstWhere((e) => e.id == _selectedDebtId);
    return debt.monthly_payment;
  }

  void updateTransactionValue(String? value) {
    var asset = _getCurrentValue();
    var debt = _getDebtValue();
    var transaction = "";

    if (debt > 0) {
      transaction = (-debt).toString();
    } else {
      transaction = _transactionValueController.text;
    }

    _transactionValueController.text = FormatterHelper.toFixed2(transaction);

    final newAssetValue = asset + FormatterHelper.getAmountFromRM( FormatterHelper.toFixed2(transaction));
    _currentValueController.text =
        FormatterHelper.toFixed2(newAssetValue.toStringAsFixed(2));
  }

  // void _updateTransactionFromCurrent(String value) {
  //    if (!_isTransactionValueLocked) {
  //      final newCurrentValue = double.tryParse(value) ?? _getCurrentValue();
  //     final transactionValue = newCurrentValue - _getCurrentValue();
  //     _transactionValueController.text = transactionValue.toStringAsFixed(2);
  //    }

  // }

  // void _updateCurrentFromTransaction(String value) {
  //   if (!_isTransactionValueLocked) {
  //     final transactionValue = double.tryParse(value) ?? 0.0;
  //     final newCurrentValue = _getCurrentValue() + transactionValue;
  //     _currentValueController.text = newCurrentValue.toStringAsFixed(2);
  //   }
  // }

  bool _validateTransaction() {
    final transactionAmount =
        FormatterHelper.getAmountFromRM(_transactionValueController.text);

    if (transactionAmount == 0.0) {
      _showError('Transaction amount cannot be zero');
      return false;
    }

    if (widget.type == 'Debt' && _selectedAssetId == -1) {
      _showError('Please select an asset to pay the debt');
      return false;
    }

    return true;
  }

  Future<void> _saveTransaction() async {
    if (!_validateTransaction()) return;

    try {
      final transactionAmount =
          FormatterHelper.getAmountFromRM(_transactionValueController.text);

      final asset = _assetList.firstWhere((e) => e.id == _selectedAssetId);
      final debt = _debtList.firstWhere((e) => e.id == _selectedDebtId);

      final transaction = Transaction(
        asset.user_code ?? debt.user_code ?? '',
        amount: transactionAmount,
        desc: _descController.text.isEmpty
            ? 'Value adjustment of ${transactionAmount.toStringAsFixed(2)}'
            : _descController.text,
        asset_id: _selectedAssetId == -1 ? null : _selectedAssetId,
        debt_id: _selectedDebtId == -1 ? null : _selectedDebtId,
        created_at: DateTime.now(),
      );

      await Transaction.insertTransaction(transaction);
      await _updateEntityValue();
      Navigator.pop(context);
    } catch (e) {
      _showError('Error saving transaction: $e');
    }
  }

  Future<void> _updateEntityValue() async {
    final newValue =
        FormatterHelper.getAmountFromRM(_currentValueController.text);

    if (_selectedAssetId != -1) {
      final asset = _assetList.firstWhere((e) => e.id == _selectedAssetId);
      asset.value = newValue;
      await Asset.updateAsset(asset);
    }

    if (_selectedDebtId != -1) {
      final debt = _debtList.firstWhere((e) => e.id == _selectedDebtId);
      debt.last_payment_date = DateTime.now();
      debt.remaining_month = debt.remaining_month - 1;
      await Debt.updateDebt(debt);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction: ${widget.type}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssetDropdown(),
            const SizedBox(height: 16),
            _buildDebtDropdown(),
            const SizedBox(height: 16),
            _buildValueFields(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedAssetId,
      items: _assetList.map((asset) {
        return DropdownMenuItem<int>(
          value: asset.id,
          child: Text(asset.name),
        );
      }).toList(),
      onChanged: widget.type == 'Asset'
          ? null
          : (value) {
              if (value != null) {
                setState(() {
                  _selectedAssetId = value;
                  _updateControllerValues();
                });
              }
            },
      decoration: const InputDecoration(
        labelText: 'Select Asset',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDebtDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedDebtId,
      items: _debtList.map((debt) {
        return DropdownMenuItem<int>(
          value: debt.id,
          child: Text(debt.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedDebtId = value;
            _updateControllerValues();
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Select Debt',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildValueFields() {
    return Column(
      children: [
        TextField(
          controller: _currentValueController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New Asset Value',
            border: OutlineInputBorder(),
          ),
          onChanged: _isTransactionValueLocked ? null : updateTransactionValue,
          readOnly: _isTransactionValueLocked,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _transactionValueController,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          decoration: const InputDecoration(
            labelText: 'Transaction Value',
            border: OutlineInputBorder(),
          ),
          onChanged: _isTransactionValueLocked ? null : updateTransactionValue,
          readOnly: _isTransactionValueLocked,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        child: const Text('Save Transaction'),
      ),
    );
  }
}
