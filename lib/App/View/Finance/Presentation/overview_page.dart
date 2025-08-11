import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../HomePage/home.dart';

class OverviewPage extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;

  const OverviewPage({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpenses;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SummaryTile('Total Income'.tr, totalIncome, Colors.green),
          SummaryTile('Total Expenses'.tr, totalExpenses, Colors.red),
          const Divider(),
          SummaryTile('Balance'.tr, balance, balance >= 0 ? Colors.blue : Colors.red),
        ],
      ),
    );
  }
}

class SummaryTile extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const SummaryTile(this.title, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
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
          title: Text(title),
          trailing: Text(
            NumberFormat.currency(symbol: '\AF'.tr).format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}