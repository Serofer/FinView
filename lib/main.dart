import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ViewExpenditurePage(),
    const AddExpenditurePage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FinView'),
          backgroundColor: Colors.blue,
        ),
        body: _pages[_selectedIndex], //Show the selected page
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'View expenditure',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_card),
                label: 'Add expenditure',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ]),
      ),
    );
  }
}

class ViewExpenditurePage extends StatefulWidget {
  const ViewExpenditurePage({super.key});
  @override
  State<ViewExpenditurePage> createState() => _ViewExpenditurePageState();
}

class _ViewExpenditurePageState extends State<ViewExpenditurePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
    appBar: AppBar(
        title: const Text('View Expenditure'),
        backgroundColor: Colors.lightBlueAccent,
      ),
    body: Center(
      child: Text('Moin page'),
    ),
    
    
    );
  }    
}
class AddExpenditurePage extends StatefulWidget {
  const AddExpenditurePage({super.key});

  @override
  State<AddExpenditurePage> createState() => _AddExpenditurePageState();
}

class _AddExpenditurePageState extends State<AddExpenditurePage> {
  //set Variables for input
  late TextEditingController inputPrice;
  late TextEditingController inputCategory;
  DateTime selectedDate = DateTime.now();
  double price = 0.0;
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
  void addExpenditure() {
    setState(() {
      //Add input
      price = double.parse(inputPrice.text);
      cost.add({
        'Date': DateFormat('dd.MM.yyyy').format(selectedDate),
        'Expenditure': price,
        'Category': category
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    ),
                    controller: inputPrice,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  //Dropdown
                  DropdownButton(
                    //TODO: align the Button in the middle
                    hint: const Text('Choose a category'),
                    items: categories.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: category,
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
                  Text('$cost'),
                ]),
          )),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings'),
    );
  }
}
