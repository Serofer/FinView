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

class ViewChartsPage extends StatefulWidget {
  const ViewChartsPage({super.key});
  @override
  State<ViewChartsPage> createState() => _ViewChartsPageState();
}

class _ViewChartsPageState extends State<ViewChartsPage> {
  late List<PieChartSectionData> sections;
  late List<Expenditure> expenses;
  String selectedTimeframe = 'Last 7 Days';
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
    refreshExpenses();
    loadPieChartData("Last 7 Days");
    loadBarChartData("Last 7 Days");
    //loadLineChartData("Last 30 Days");
    loadTableData("Last 7 Days");
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
    //Initialize PieData and call calculate
    PieData pieData = PieData();
    setState(() => pieLoading = true);

    await Future.delayed(const Duration(seconds: 1));
    await pieData.calculate(timeframe);
    sections = getSections();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => pieLoading = false);
  }

/*
  Future loadLineChartData() async {
    setState(() => lineLoading = true);
    BarData barData = BarData();
    //reference to needed functions
    await barData.createBarData("month");
    setState(() => lineLoading = false);
  }*/
  Future loadBarChartData(String? timeframe) async {
    setState(() => barLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    BarData barData = BarData();
    await Future.delayed(const Duration(seconds: 1));
    await barData.createBarData(timeframe);
    setState(() => barLoading = false);
  }

  Future loadTableData(String? timeframe) async {
    setState(() => tableLoading = true);
    DataForTable tableData = DataForTable();
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
            barLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBar(),
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
      height: 500,
      //change to staggered view
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: sections,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: PieData.data
                          .map(
                            (data) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: buildIndicator(
                                    color: data.color, text: data.name)),
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
          padding: const EdgeInsets.only(top: 16),
          child: BarChartWidget(),
        ),
      ),
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
                    // Update data immediately when an item is selected
                    loadBarChartData(selectedTimeframe);
                    loadTableData(selectedTimeframe);
                    loadPieChartData(selectedTimeframe);
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
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

  Widget _buildTable() {
    return SizedBox(
      height: 500,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TableWidget(),
        ),
      ),
    );
  }
/*
  Widget _buildLine () {
    return Container(
      height: 500,
      child: Card(
        child: Linechart(
          LineChartData( //according to filter
            minX: 0,
            maxX: 11,
            minY: 0,
            maxX: 3,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 30),
                  FlSpot(2, 40),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }*/
}
