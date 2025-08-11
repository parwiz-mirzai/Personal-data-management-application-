import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../HomePage/home.dart';
import '../Data/user_data.dart';

class ExpensesPage extends StatelessWidget {
  final List<Transaction> expenseItems;
  final Function onDelete;
  final Function onUpdate;

  const ExpensesPage({
    super.key,
    required this.expenseItems,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseItems.isEmpty) {
      return  Center(child: Text('No expenses recorded yet.'.tr));
    }

    return ListView.builder(
      itemCount: expenseItems.length,
      itemBuilder: (_, i) {
        final tx = expenseItems[i];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  secondaryColor,
                  primaryColor,
                ],
              ),
            ),
            child: ListTile(
              title: Text(tx.source),
              subtitle: Text(DateFormat.yMMMd().format(tx.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    NumberFormat.currency(symbol: '\AF').format(tx.amount),
                    style: const TextStyle(color: Colors.red),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showUpdateDialog(context, tx);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, tx.transactionId);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, Transaction transaction) {
    final TextEditingController sourceController =
        TextEditingController(text: transaction.source);
    final TextEditingController amountController =
        TextEditingController(text: transaction.amount.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:  Text('Update Expense'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sourceController,
                decoration:  InputDecoration(labelText: 'Source'.tr),
              ),
              TextField(
                controller: amountController,
                decoration:  InputDecoration(labelText: 'Amount'.tr),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedTransaction = Transaction(
                  transactionId: transaction.transactionId,
                  type: transaction.type,
                  source: sourceController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  date: transaction.date,
                  notes: transaction.notes,
                );
                onUpdate(updatedTransaction);
                Navigator.of(ctx).pop();
              },
              child:  Text('Update'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:  Text('Cancel'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int? transactionId) {
    if (transactionId == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:  Text('Delete Transaction'.tr),
          content:
               Text('Are you sure you want to delete this transaction?'.tr),
          actions: [
            TextButton(
              onPressed: () {
                onDelete(transactionId);
                Navigator.of(ctx).pop();
              },
              child:  Text('Yes'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:  Text('No'.tr),
            ),
          ],
        );
      },
    );
  }
}
