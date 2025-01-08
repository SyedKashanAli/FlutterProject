import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isSpending;  // true for spending, false for earning

  Transaction({
    required this.category,
    required this.amount,
    required this.date,
    required this.isSpending,
  });
}
