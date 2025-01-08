import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;  // For editing
  final Function(Transaction) onSave;

  const TransactionForm({this.transaction, required this.onSave});

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Salary', 'Investment'];
  bool _isSpending = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _categoryController.text = widget.transaction!.category;
      _amountController.text = widget.transaction!.amount.toString();
      _isSpending = widget.transaction!.isSpending;
      _selectedDate = widget.transaction!.date;
    }
  }

  void _submitTransaction() {
    final category = _categoryController.text;
    final amount = double.tryParse(_amountController.text);
    if (category.isEmpty || amount == null || amount <= 0) {
      return;
    }

    final transaction = Transaction(
      category: category,
      amount: amount,
      date: _selectedDate,
      isSpending: _isSpending,
    );

    widget.onSave(transaction);
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Category'),
            value: _categoryController.text.isEmpty ? null : _categoryController.text,
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _categoryController.text = value!;
              });
            },
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          DropdownButtonFormField<bool>(
            decoration: InputDecoration(labelText: 'Type'),
            value: _isSpending,
            items: [
              DropdownMenuItem(value: true, child: Text('Spending')),
              DropdownMenuItem(value: false, child: Text('Earning')),
            ],
            onChanged: (value) {
              setState(() {
                _isSpending = value!;
              });
            },
          ),
          Row(
            children: [
              Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _submitTransaction,
            child: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
          ),
        ],
      ),
    );
  }
}
