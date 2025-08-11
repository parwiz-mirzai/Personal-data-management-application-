import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:get/get.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import '../../../../Core/Sqlite/database.dart';
import '../Data/user_data.dart';
import 'expenses_page.dart';
import 'incom_page.dart';
import 'overview_page.dart';
import 'transaction.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({Key? key}) : super(key: key);

  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  List<Transaction> incomeItems = [];
  List<Transaction> expenseItems = [];
  DateTime? startDate;
  DateTime? endDate;
  final db = DatabaseHelper();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    // Fetch from SQLite
    List<Transaction> localTransactions = await db.fetchTransactions();
        if(mounted){
      setState(() {
        
      });
    }
    
    // Fetch from Firebase
    final snapshot = await firestore.collection('transactions').get();
    List<Transaction> firebaseTransactions = snapshot.docs.map((doc) {
      final data = doc.data();
      return Transaction.fromMap({
        ...data,
        'id': data['localId'],  // Use local ID from Firebase
        'firestoreId': doc.id,  // Store Firestore ID
      });
    }).toList();
    if(mounted){
      setState(() {
        
      });
    }

    // Merge and remove duplicates
    final Map<int, Transaction> uniqueTransactions = {};
    for (final tx in [...localTransactions, ...firebaseTransactions]) {
      uniqueTransactions[tx.transactionId!] = tx;
    }

if(mounted){
      setState(() {
      incomeItems = uniqueTransactions.values
          .where((tx) => tx.type == TransactionType.income)
          .toList();
      expenseItems = uniqueTransactions.values
          .where((tx) => tx.type == TransactionType.expense)
          .toList();
    });
}
  }

  Future<void> _addTransaction(Transaction transaction) async {
    // Save to SQLite
    final localId = await db.insertTransaction(transaction);
    transaction.transactionId = localId;
    if(mounted){
      _fetchTransactions();
    }

    // Prepare for Firebase
    final txMap = transaction.toMap();
    txMap['localId'] = localId;  // Store local ID in Firebase

    // Check for duplicates in Firebase
    final duplicateSnapshot = await firestore.collection('transactions')
        .where('localId', isEqualTo: localId)
        .limit(1)
        .get();

    if (duplicateSnapshot.docs.isEmpty) {
      // Add to Firebase
      await firestore.collection('transactions').add(txMap);
    }

    _fetchTransactions();
  }

  Future<void> _updateTransaction(Transaction updatedTransaction) async {
    // Update in SQLite
    await db.updateTransaction(updatedTransaction);

    // Update in Firebase if exists
    final snapshot = await firestore.collection('transactions')
        .where('localId', isEqualTo: updatedTransaction.transactionId)
        .limit(1)
        .get();

        _fetchTransactions();



    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update(updatedTransaction.toMap());
    } else {
      // Add to Firebase if missing
      final txMap = updatedTransaction.toMap();
      txMap['localId'] = updatedTransaction.transactionId;
      await firestore.collection('transactions').add(txMap);
    }


      setState(() {
        _fetchTransactions();
      });
    
  }

  Future<void> _deleteTransaction(int id) async {
    // Delete from SQLite
    await db.deleteTransaction(id);

    // Delete from Firebase
    final snapshot = await firestore.collection('transactions')
        .where('localId', isEqualTo: id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
setState(() {
    _fetchTransactions();
});
  }

  Future<void> _filterByDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });

      // Fetch from SQLite
      List<Transaction> localTransactions = 
          await db.fetchTransactionsByDateRange(startDate!, endDate!);
      
      // Fetch from Firebase
      final snapshot = await firestore.collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate!.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate!.toIso8601String())
          .get();
      
      List<Transaction> firebaseTransactions = snapshot.docs.map((doc) {
        final data = doc.data();
        return Transaction.fromMap({
          ...data,
          'id': data['localId'],
          'firestoreId': doc.id,
        });
      }).toList();

      // Merge results
      final allTransactions = [...localTransactions, ...firebaseTransactions];
      
      setState(() {
        incomeItems = allTransactions
            .where((tx) => tx.type == TransactionType.income)
            .toList();
        expenseItems = allTransactions
            .where((tx) => tx.type == TransactionType.expense)
            .toList();
      });
    }
  }

  void _showAllTransactions() => _fetchTransactions();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title:  Center(child: Text('My Finance'.tr)),
          bottom:  TabBar(
            tabs: [
              Tab(text: 'Overview'.tr),
              Tab(text: 'Income'.tr),
              Tab(text: 'Expenses'.tr),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _filterByDateRange,
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _showAllTransactions,
            ),
         
          ],
        ),
        body: TabBarView(
          children: [
            OverviewPage(
              totalIncome: incomeItems.fold(0, (sum, item) => sum + item.amount),
              totalExpenses: expenseItems.fold(0, (sum, item) => sum + item.amount),
            ),
            IncomePage(
              incomeItems: incomeItems, 
              onDelete: _deleteTransaction, 
              onUpdate: _updateTransaction,
            ),
            ExpensesPage(
              expenseItems: expenseItems, 
              onDelete: _deleteTransaction, 
              onUpdate: _updateTransaction,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => TransactionForm(onSave: _addTransaction),
            );
          },
        ),
      ),
    );
  }
}