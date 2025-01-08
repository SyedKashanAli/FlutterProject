import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';  // Corrected import statement
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../widgets/summary_card.dart';
import '../screens/budget_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/expense_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalEarnings = 0;
  double _totalSpendings = 0;
  double _profit = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalValues();
  }

  void _calculateTotalValues() {
    final box = Hive.box<Transaction>('transactions');
    double earnings = 0;
    double spendings = 0;

    for (var transaction in box.values) {
      if (transaction.isSpending) {
        spendings += transaction.amount;
      } else {
        earnings += transaction.amount;
      }
    }

    setState(() {
      _totalEarnings = earnings;
      _totalSpendings = spendings;
      _profit = _totalEarnings - _totalSpendings;
    });
  }

  void _addTransaction(Transaction transaction) {
    final box = Hive.box<Transaction>('transactions');
    box.add(transaction);
    _calculateTotalValues();
  }

  void _editTransaction(int index, Transaction transaction) {
    final box = Hive.box<Transaction>('transactions');
    box.putAt(index, transaction);
    _calculateTotalValues();
  }

  void _deleteTransaction(int index) {
    final box = Hive.box<Transaction>('transactions');
    box.deleteAt(index);
    _calculateTotalValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsightsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BudgetScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.money_off),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenseScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TransactionForm(onSave: _addTransaction),
            // Updated Summary Cards with appropriate colors
            SummaryCard(
              title: 'Total Earnings',
              amount: _totalEarnings.toStringAsFixed(2),
              icon: Icons.attach_money,
              color: Colors.green,  // Earnings - Green color
            ),
            SummaryCard(
              title: 'Total Spendings',
              amount: _totalSpendings.toStringAsFixed(2),
              icon: Icons.shopping_cart,
              color: Colors.red,  // Spendings - Red color
            ),
            SummaryCard(
              title: 'Profit',
              amount: _profit.toStringAsFixed(2),
              icon: Icons.trending_up,
              color: Colors.blue,  // Profit - Blue color
            ),
            // Add a beautiful chart of profits
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateChartData(),
                        isCurved: true,
                        color: Colors.blue,  // Corrected property name
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.3),  // Corrected property name
                        ),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box<Transaction>('transactions').listenable(),
              builder: (context, Box<Transaction> box, _) {
                final transactions = box.values.toList().reversed.toList();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text(transaction.category),
                      subtitle: Text(
                        '\$${transaction.amount.toStringAsFixed(2)} - ${transaction.isSpending ? 'Spending' : 'Earning'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Edit Transaction'),
                                    content: TransactionForm(
                                      transaction: transaction,
                                      onSave: (editedTransaction) {
                                        _editTransaction(index, editedTransaction);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteTransaction(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    final box = Hive.box<Transaction>('transactions');
    List<FlSpot> spots = [];
    double cumulativeProfit = 0;
    for (var transaction in box.values) {
      cumulativeProfit += transaction.isSpending ? -transaction.amount : transaction.amount;
      spots.add(FlSpot(transaction.date.millisecondsSinceEpoch.toDouble(), cumulativeProfit));
    }
    return spots;
  }
}
