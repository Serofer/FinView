import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';

class ViewExpenditurePage extends StatefulWidget {
  const ViewExpenditurePage({super.key});
  @override
  State<ViewExpenditurePage> createState() => _ViewExpenditurePageState();
}

class _ViewExpenditurePageState extends State<ViewExpenditurePage> {
  late List<Expenditure> expenses;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshExpenses();
  }

  @override
  void dispose() {
    //SpentDatabase.instance.close();

    super.dispose();
  }

  Future refreshExpenses() async {
    setState(() => isLoading = true);
    expenses = await SpentDatabase.instance.readAllExpenditure();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Expenditure'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : expenses.isEmpty
                ? const Text(
                    'No Expenditure',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                : showData(),
      ),
    );
  }

  Widget showData() => ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expenditure = expenses[index];
          return Card(
            child: ListTile(
              title: Text(expenditure.category),
              trailing: Text(expenditure.amount.toString()),
            ),
          );
        },
      );
}