import 'package:hive/hive.dart';
import '../models/transaction.dart';

class HiveBoxes {
  static Box<Transaction> getTransactions() => Hive.box<Transaction>('transactions');
}
