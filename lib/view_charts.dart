import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/pie_chart_sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/pie_data.dart';
import 'package:fin_view/charts/indicators_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ViewChartsPage extends StatefulWidget {
  const ViewChartsPage({super.key});
  @override
  State<ViewChartsPage> createState() => _ViewChartsPageState();
}

class _ViewChartsPageState extends State<ViewChartsPage> {
  late List<PieChartSectionData> sections;
  late List<Expenditure> expenses;
  bool isLoading = false;
  bool pieLoading = false;
  bool LineLoading = false;
  int touchedIndex = 0;

  @override
  void initState() {
    super.initState();
    refreshExpenses();
    loadPieChartData();
    loadLineChartData();
    
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

  Future loadPieChartData() async {
    //Initialize PieData and call calculate
    PieData pieData = PieData();
    setState(() => pieLoading = true);

    await Future.delayed(Duration(seconds: 1));
    await pieData.calculate();
    sections = getSections();
    await Future.delayed(Duration(seconds: 1));
    setState(() => pieLoading = false);
    print(pieLoading);
  }

  Future loadLineChartData() async {
    setState(() => LineLoading = true);
    //reference to needed functions
    await barData.createBarData();
    setState(() => LineLoading = false);
  }

  @override
  Widget build(BuildContext context) {//maybe scrollable widget

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Charts'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: <Widget>[
          pieLoading
              ? Center(child: const CircularProgressIndicator())
              : _buildPie(),
          Text("hello"),
        ],
      ),
    );
  }

  Widget _buildPie() {
    return Container(
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
    return Container(
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
