import 'package:fin_view/data/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarTitles {
    static SideTitles getTopBottomTitles() => SideTitles(
        showTitles: true,
        getTextStyles: (value) =>
        const TextStyle(color: Colors.white, fontSize: 10),
        margin: 10,
        getTitles: (double id) => BarData.barData
            .firstWhere((element) => element.id == id.toInt())
            .name, 
    );

    static SideTitles getSideTitles() => SideTitles(
        showTitles: true,
        getTextStyles: (value) =>
            const TextStyle(color: Colors.white, fontSize: 10),

        interval: BarData.interval.toDouble(),

        getTitles: (double value) => '${value.toInt()}',
    );
} 
'