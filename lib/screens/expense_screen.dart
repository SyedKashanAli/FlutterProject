import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Transaction>('transactions');
    final spendings = box.values.where((transaction) => transaction.isSpending).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: spendings.length,
        itemBuilder: (context, index) {
          final transaction = spendings[index];
          return ListTile(
            title: Text(transaction.category),
            subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
            trailing: Text(transaction.date.toLocal().toString().split(' ')[0]),
          );
        },
      ),
    );
  }
}
