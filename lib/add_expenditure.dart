import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpenditurePage extends StatefulWidget {
  const AddExpenditurePage({super.key}); //maybe remove super.key

  @override
  State<AddExpenditurePage> createState() => _AddExpenditurePageState();
}

class _AddExpenditurePageState extends State<AddExpenditurePage> {
  //maybe replace AddExpenditurePage with ViewExpenditurePage
  //set Variables for input
  //final _formKey = GlobalKey<FormState>();
  late TextEditingController inputPrice;
  late TextEditingController inputCategory;
  late DateTime selectedDate = DateTime.now();
  double? price;
  String? category;
  List categories = ['Food', 'Event', 'Education', 'Other'];

  List<Map<String, dynamic>> cost = [
    {'Date': '2022-01-01', 'Expenditure': 18.90, 'Category': 'Food'},
    {'Date': '2022-01-01', 'Expenditure': 5.00, 'Category': 'Event'}
  ];

  @override
  void initState() {
    super.initState();
    inputPrice = TextEditingController();
    inputCategory = TextEditingController();
  }

  @override
  void dispose() {
    inputPrice.dispose();
    inputCategory.dispose();

    super.dispose();
  }

  //Add Expenditure
  Future addExpenditure() async {
    price ??= 0;
    category ??= 'Food';
    if (inputPrice.text.isNotEmpty == true) {
      double number = double.parse(inputPrice.text);
      String newText = number.toStringAsFixed(2);
      price = double.parse(newText);
    }

    final expenditure = Expenditure(
      amount: price!,
      category: category!,
      date: selectedDate,
    );

    await SpentDatabase.instance.create(expenditure);
    //Add input
    setState(() {
      cost.add({
        'Date': DateFormat('yyyy-mm-dd').format(selectedDate),
        'Expenditure': price,
        'Category': category
      });
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    //remove AppBar and maybe change scaffold
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expenditure'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  //Date
                  Text(
                    DateFormat('dd.MM.yyyy').format(selectedDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(height: 16.0),
                  //DatePicker
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (dateTime != null) {
                        setState(() {
                          selectedDate = dateTime;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                  const SizedBox(height: 16.0),
                  //Price
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    controller: inputPrice,
                    onChanged: (value) {
                      double newValue = 0.0;
                      if (value != null) {
                        double? newValue = double.tryParse(value);
                      }
                      
                      String next = newValue.toStringAsFixed(2);
                      price = double.parse(next);
                      
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  //Dropdown
                  DropdownButton(
                    hint: const Text('Choose a category'),
                    items: categories.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: category, // as expected wrong
                    onChanged: (selectedValue) {
                      setState(() {
                        category = selectedValue.toString();
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  //Submit
                  FloatingActionButton.extended(
                    onPressed: addExpenditure,
                    backgroundColor: Colors.lightBlueAccent,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expenditure'),
                  ),
                  const SizedBox(height: 16.0),
                  //Text('$cost'),
                ]),
          )),
    );
  }
}
