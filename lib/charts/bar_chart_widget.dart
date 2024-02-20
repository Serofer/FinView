import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
    final double barWidth = 22;
    final double barHeight = 100; //calculate barHeight based on max spent in timeframe
    final double groupSpace = 12; //is the space between the bars

    @override
    Widget build(BuildContext context) => BarChart(
        BarChartData(
            alignment: BarChartAlignment.center,
            maxY: barHeight;
            minY: 0;
            groupSpace: groupSpace,
            //barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
                topTitles: BarTitles.getTopBottomTitles(),
                bottomTitles: BarTitles.getTopBottomTitles(),
                leftTitles: BarTitles.getSideTitles(),
                rightTitles: BarTitles.getSideTitles(),
            ),
            girdData: FlGridData(
                checkToShowHorizontalLine: (value) => value % BarData.interval == 0,
                getDrawingHorizontalLine: (value) {
                    return FlLine(
                        color: const Color(0xff2a7747),
                        strokeWidth: 0.8,
                    ),
                },
            ),
            barGroups: BarData.BarData.map(
                (data) => BarChartGroupData(
                    x: data.id,
                    barRods: [
                        BarChartRodData(
                            y: data.y,
                            width: barWidth,
                            colors: [data.color],
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                            ),
                        ),
                    ],
                ),
            )
            .toList();
        ),
    );
}