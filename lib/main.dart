import 'package:flutter/material.dart';
import 'package:fin_view/view_expenditure.dart';
import 'package:fin_view/settings.dart';
import 'package:fin_view/view_charts.dart';
import 'package:fin_view/user_data/timeframe_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //SpentDatabase.instance.deleteAll();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  String selectedTimeframe = TimeframeManager().selectedTimeframe;

  final List<Widget> _pages = [
    const ViewExpenditurePage(),
    const ViewChartsPage(),
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
        body: _pages[_selectedIndex], //Show the selected page
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.data_saver_off),
                label: 'View expenditure',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'View Charts',
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
