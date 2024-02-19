import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
    final double barWidth = 22;
    final double barHeight = 100; //calculate barHeight based on max spent in timeframe
    final double groupSpace = 20;

    @override
    Widget build(BuildContext context) => BarChart(
        BarChartData(
            alignment: BarChartAlignment.center,
            maxY: barHeight;
            minY: 0;
            groupSpace: groupSpace,
            //barTouchData: BarTouchData(enabled: true),
            barGroups: BarData.BarData.map(
                (data) =>
            )
            .toList();
        ),
    );
}