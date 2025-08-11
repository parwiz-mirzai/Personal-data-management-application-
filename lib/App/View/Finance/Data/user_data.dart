
enum TransactionType { income, expense }

class Transaction {
  late  int? transactionId;
  final TransactionType type;
  final String source;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? category;

  Transaction({
    this.transactionId,
    required this.type,
    required this.source,
    required this.amount,
    required this.date,
    this.notes,
    this.category,
  });

  // Convert a Transaction into a Map for SQLite.
  Map<String, Object?> toMap() {
    return {
      'id': transactionId,
      'type': type == TransactionType.income ? 1 : 0,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'category': category,
    };
  }

  // Create a Transaction object from a SQLite row.
  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionId: map['id'],
      type: map['type'] == 1 ? TransactionType.income : TransactionType.expense,
      source: map['source'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      category: map['category'],
    );
  }
}