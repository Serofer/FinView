import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/pie_charts_sections.dart';

class ViewChartsPage extends StatefulWidget {
    const ViewChartsPage({super.key});
    @override
    State<VieChartsPage> createState() => _ViewChartsPageState();
}

class _ViewChartsPageState extends State<ViewChartsPage> {


   /* @override
    void initState() {
        super.initState();
        refreshExpenses();
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
    */
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('View Charts'),
                backgroundColor: Colors.lightBlueAccent,
            ),
            body: Center(
                child: PieChart(
                    PieChartData(
                        sections: getSections(),
                    ),
                ),
            ),
        );
    }
}