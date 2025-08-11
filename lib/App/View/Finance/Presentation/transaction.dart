import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Data/user_data.dart';

class TransactionForm extends StatefulWidget {
  final Function onSave;

  const TransactionForm({Key? key, required this.onSave}) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.income;

  void _submitForm() {
    final source = _sourceController.text;
    final amount = double.tryParse(_amountController.text);

    if (source.isEmpty || amount == null || amount <= 0) {
      return; // Optionally show a message to the user
    }

    final transaction = Transaction(
      type: _selectedType,
      source: source,
      amount: amount,
      date: DateTime.now(),
    );

    widget.onSave(transaction);
    _sourceController.clear();
    _amountController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _sourceController,
                decoration: InputDecoration(labelText: 'Source'.tr,border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'.tr,border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
            ListTile(
              title: Text('Income'.tr),
              leading: Radio<TransactionType>(
                value: TransactionType.income,
                groupValue: _selectedType,
                onChanged: (TransactionType? value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Expense'.tr),
              leading: Radio<TransactionType>(
                value: TransactionType.expense,
                groupValue: _selectedType,
                onChanged: (TransactionType? value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Add Transaction'.tr),
            ),
          ],
        ),
      ),
    );
  }
}