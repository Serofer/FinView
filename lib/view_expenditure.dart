import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/add_expenditure.dart'


class ViewExpenditurePage extends StatefulWidget {
  const ViewExpenditurePage({super.key});
  @override
  State<ViewExpenditurePage> createState() => _ViewExpenditurePageState();
}

class _ViewExpenditurePageState extends State<ViewExpenditurePage> {
  
  /*showOverlay(BuildContext context) async {
    OverlayState overlayState = Overla.of(context);
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
        /*actions: <Widget>[
          icon:const Icon(Icons.add),
          onPressed: (){
            _showAddExpenditureModal(context);
          },
        ],*/
      ),
      body: Column(
      children: [
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
      Center(

      ),
      ]
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
              subtitle: Text(expenditure.date.toString()),
            ),
          );
        },
      );

      /*void _showAddExpenditureModas(BuildContext context) {
        showModalBottomSheet(
          context: context,
          builder: (BuildCjontext context) {
            return Container(
              height: 300, //Adjust height as needed
              child: AddExpenditurePage(),
            );
          },
        );
      } */
 
  Widget showPieChart() {
    
  }
}
