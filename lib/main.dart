import 'dart:ffi';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  List<Widget> _pages = [
    ViewExpenditurePage(),
    AddExpenditurePage(),
    SettingsPage(),
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

class ViewExpenditurePage extends StatelessWidget {
  const ViewExpenditurePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      //Add input
      child: Text('View expenditure'),
    );
  }
}

class AddExpenditurePage extends StatefulWidget {
  const AddExpenditurePage({super.key});

  @override
  State<AddExpenditurePage> createState() => _AddExpenditurePageState();
}

class _AddExpenditurePageState extends State<AddExpenditurePage> {
  late TextEditingController inputPrice;
  late TextEditingController inputCategory;
  double price = 0.0;
  String category = '';
  var information1 = {'Expenditure': 18.90, 'Category': 'Food'};
  var information2 = {'Expenditure': 5.00, 'Category': 'Event'};
  List<Map<String, dynamic>> cost = [
    {'Expenditure': 18.90, 'Category': 'Food'},
    {'Expenditure': 5.00, 'Category': 'Event'}
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Price',
              border: OutlineInputBorder(),
            ),
            controller: inputPrice,
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Category',
              border: OutlineInputBorder(),
            ),
            controller: inputCategory,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                //Add input
                price = double.parse(inputPrice.text);
                category = inputCategory.text;
                cost.add({'Expenditure': price, 'Category': category});
              });
            },
            child: Text('Submit'),
            backgroundColor: Colors.blue,
          ),
          Text('$cost'),
        ]),
      ),
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
