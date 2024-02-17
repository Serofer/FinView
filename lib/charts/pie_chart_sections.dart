import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/view_charts.dart';
import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/pie_data.dart';

List<PieChartSectionData> getSections() => PieData.data
    .asMap()
    .map<int, PieChartSectionData>((index, data) {
      final value = PieChartSectionData(
        color: data.color,
        value: data.percent,
        title: '${data.percent}%',
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
      return MapEntry(index, value);
    })
    .values
    .toList();
