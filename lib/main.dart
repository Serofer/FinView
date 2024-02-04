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

class AddExpenditurePage extends StatelessWidget {
  const AddExpenditurePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Add expenditure'),
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
