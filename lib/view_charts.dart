import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/pie_chart_sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/pie_data.dart';
import 'package:fin_view/charts/indicators_widget.dart';
import 'package:fin_view/charts/data/pie_data.dart';

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
  int touchedIndex = 0;

  @override
  void initState() {
    super.initState();
    refreshExpenses();
    loadPieChartData();
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
    await pieData.calculate();
    sections = getSections(touchedIndex);
    setState(() => pieLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Charts'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: pieLoading ? CircularProgressIndicator() : _buildChildren(),
    );
  }

  Widget _buildChildren() {
    return Center(
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
}
