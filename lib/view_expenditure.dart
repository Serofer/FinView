import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/add_expenditure.dart';
import 'package:intl/intl.dart';

class ViewExpenditurePage extends StatefulWidget {
  const ViewExpenditurePage({super.key});
  @override
  State<ViewExpenditurePage> createState() => _ViewExpenditurePageState();
}

class _ViewExpenditurePageState extends State<ViewExpenditurePage> {
  /*showOverlay(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
  }*/
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddExpenditureModal(context);
            },
          )
        ],
      ),
      body: //Column(children: [
          Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : expenses.isEmpty
                ? const Text(
                    'No Expenditure',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  )
                : showData(),
      ),
      //Center(),
      //]),
    );
  }

  Widget showData() => ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expenditure = expenses[index];
          return Dismissible(
            key: Key(expenditure.id.toString()), // Unique key for each item
            onDismissed: (direction) {
              // Delete the expenditure from the database
              SpentDatabase.instance
                  .delete(expenditure.id!); // Call your database function here
              setState(() {
                // Remove the item from the list
                expenses.removeAt(index);
              });
              // Optionally, show a snackbar or confirmation dialog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Item deleted'),
              ));
            },
            confirmDismiss: (direction) async {
              // Optionally, show a confirmation dialog before deletion
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text('Are you sure you want to delete this item?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('DELETE'),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              child: ListTile(
                title: Text(expenditure.category),
                trailing: Text(expenditure.amount.toString()),
                subtitle: Text(DateFormat('dd.MM.yyyy')
                    .format(expenditure.date)
                    .toString()),
              ),
            ),
          );
        },
      );

  void _showAddExpenditureModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const SizedBox(
          height: 500, //Adjust height as needed
          child: AddExpenditurePage(),
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          refreshExpenses();
        });
      }
    });
  }
}
