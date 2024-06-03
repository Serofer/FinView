import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/pie_data.dart';

List<PieChartSectionData> getSections() => PieData.data
    .asMap()
    .map<int, PieChartSectionData>((index, data) {
      /*final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;*/

      final value = PieChartSectionData(
        color: data.color,
        value: data.percent,
        title: '${data.percent}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
      );
      return MapEntry(index, value);
    })
    .values
    .toList();
