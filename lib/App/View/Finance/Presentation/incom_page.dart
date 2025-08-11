import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:intl/intl.dart';
import '../Data/user_data.dart';

class IncomePage extends StatelessWidget {
  final List<Transaction> incomeItems;
  final Function onDelete;
  final Function onUpdate;

  const IncomePage({
    super.key,
    required this.incomeItems,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: incomeItems.length,
      itemBuilder: (_, i) {
        final tx = incomeItems[i];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
                    style: const TextStyle(color: Colors.green),
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
          title:  Text('Update Transaction'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sourceController,
                decoration:  InputDecoration(labelText: 'Source'.tr,border: OutlineInputBorder()),
              ),
              TextField(
                controller: amountController,
                decoration:  InputDecoration(labelText: 'Amount'.tr,border: OutlineInputBorder()),
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
          content:  Text('Are you sure you want to delete this transaction?'.tr),
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