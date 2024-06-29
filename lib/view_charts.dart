import 'package:fin_view/user_data/timeframe_manager.dart';
import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/pie_chart_sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/pie_data.dart';
import 'package:fin_view/charts/indicators_widget.dart';
import 'package:fin_view/charts/table_widget.dart';
import 'package:fin_view/charts/bar_chart_widget.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:fin_view/charts/data/table_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_view/user_data/timeframe_manager.dart';

class ViewChartsPage extends StatefulWidget {
  const ViewChartsPage({super.key});
  @override
  State<ViewChartsPage> createState() => _ViewChartsPageState();
}

class _ViewChartsPageState extends State<ViewChartsPage> {
  late List<PieChartSectionData> sections;
  late List<Expenditure> expenses;
  String selectedTimeframe = TimeframeManager().selectedTimeframe;
  
  List timeframes = [
    'Last 7 Days',
    'Last 30 Days',
    'This Month',
    'This Year',
    'All Time'
  ];
  bool isLoading = false;
  bool pieLoading = false;
  bool lineLoading = false;
  bool tableLoading = false;
  bool barLoading = false;
  int touchedIndex = 0;

  

  @override
  void initState() {
    super.initState();
    _loadSelectedTimeframe();
    refreshExpenses();
    loadPieChartData(selectedTimeframe);
    loadBarChartData(selectedTimeframe);
    //loadLineChartData("Last 30 Days");
    loadTableData(selectedTimeframe);
  }

  @override
  void dispose() {
    //SpentDatabse.instance.close();

    super.dispose();
  }

  Future refreshExpenses() async {
    setState(() => isLoading = true);
    expenses = await SpentDatabase.instance.readAllExpenditure();
    setState(() => isLoading = false);
  }

  Future loadPieChartData(String? timeframe) async {
    selectedTimeframe = TimeframeManager().selectedTimeframe;
    _loadSelectedTimeframe();
    //Initialize PieData and call calculate
    PieData pieData = PieData();
    setState(() => pieLoading = true);

    //await Future.delayed(const Duration(seconds: 1));
    await pieData.calculate(timeframe);
    sections = getSections();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => pieLoading = false);
  }


  Future loadBarChartData(String? timeframe) async {
    selectedTimeframe = TimeframeManager().selectedTimeframe;
    _loadSelectedTimeframe();
    setState(() => barLoading = true);
    //await Future.delayed(const Duration(seconds: 1));
    BarData barData = BarData();
    await Future.delayed(const Duration(seconds: 1));
    await barData.createBarData(timeframe);
    setState(() => barLoading = false);
  }

  Future loadTableData(String? timeframe) async {
    selectedTimeframe = TimeframeManager().selectedTimeframe;
    _loadSelectedTimeframe();
    setState(() => tableLoading = true);
    //await Future.delayed(const Duration(seconds: 1));
    DataForTable tableData = DataForTable();
    await Future.delayed(const Duration(seconds: 1));
    await tableData.createTableData(timeframe);
    setState(() => tableLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Column with a SingleChildScrollView
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Charts'),
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(selectedTimeframe,
                style: const TextStyle(color: Colors.black, fontSize: 24)),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterModal(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            pieLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPie(),
                const SizedBox(height: 16.0),
            barLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBar(),
                const SizedBox(height: 16.0),
            tableLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPie() {
  return SizedBox(
    height: 400, // Reduced height
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Column(
          children: [
            const Text(
              'Pie Chart', // Title text
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ), 
            Expanded(
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 30, // Adjusted for less space in the center
                  sections: sections,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: PieData.data
                        .map(
                          (data) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: buildIndicator(
                                color: data.color, text: data.name),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildBar() {
  return SizedBox(
    height: 500,
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(      
          children: [
            const Text(
              'Bar Chart', // Title text
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
             // Spacing between title and chart
            Expanded(
              child: BarChartWidget(),
            ),
          ],
        ),
      ),
    ),
  );
}

 Widget _buildTable() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Text(
              'Table', // Title text
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Spacing between title and chart
            TableWidget(),
            ],
          ),
        ),
      );
    },
  );
}


  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Use StatefulBuilder to rebuild the dialog's UI when the state changes
            return AlertDialog(
              title: const Text('Select Filter'),
              content: DropdownButton(
                hint: const Text('Choose a category'),
                items: timeframes.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: selectedTimeframe,
                onChanged: (selectedValue) {
                  setState(() {
                    selectedTimeframe = selectedValue.toString();
                    //save the selected timeframe
                    _saveSelectedTimeframe(selectedTimeframe);
                    
                    
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Update data immediately when the user closes the dialog
                    loadBarChartData(selectedTimeframe);
                    loadTableData(selectedTimeframe);
                    loadPieChartData(selectedTimeframe);
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveSelectedTimeframe(String? selectedTimeframe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimeframe', selectedTimeframe!);
  }



  void _loadSelectedTimeframe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTimeframe = prefs.getString('selectedTimeframe') ?? 'Last 7 Days';
      // Save the loaded timeframe in the singleton
      TimeframeManager().selectedTimeframe = selectedTimeframe;
      // Optionally, load the data based on the saved timeframe
      
    });
  }
}
