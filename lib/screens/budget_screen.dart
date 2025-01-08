import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    await Hive.openBox('settings'); // Ensure the box is opened
    final box = Hive.box('settings');
    final budget = box.get('monthlyBudget', defaultValue: 0.0);
    _budgetController.text = budget.toString();
  }


  void _saveBudget() {
    final box = Hive.box('settings');
    final budget = double.tryParse(_budgetController.text) ?? 0.0;
    box.put('monthlyBudget', budget);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Transaction>('transactions');
    final earnings = box.values.where((transaction) => !transaction.isSpending).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Monthly Budget'),
            ),
            ElevatedButton(
              onPressed: _saveBudget,
              child: Text('Save Budget'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: earnings.length,
                itemBuilder: (context, index) {
                  final transaction = earnings[index];
                  return ListTile(
                    title: Text(transaction.category),
                    subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
