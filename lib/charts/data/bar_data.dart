import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';

class BarData {
  static int interval = 10; //change according to max bar
  late List<dynamic> dataFromBase;
  static late List<Data> barData;
  static double barHeight = 0.0;

  Future<void> createBarData(String? timeframe) async {
    barHeight = 0.0;
    barData = await SpentDatabase.instance.queryForBar(timeframe, true);
    for (int i = 0; i < barData.length; i++) {
      for (int j = 0; j < barData[i].rodData.length; j++) {
        barHeight = barData[i].rodData[j].barHeight > barHeight
            ? ((barData[i].rodData[j].barHeight / 10).ceil() * 10).toDouble()
            : barHeight;
      }
    }
  }

  //createBarData();
  //calculate each Data -> array with values: id, name, color...
}

class Data {
  final int id;
  final String name;
  List<BarChartRodDataClass> rodData;

  Data({
    required this.id,
    required this.name,
    required this.rodData,
  });
}

class BarChartRodDataClass {
  double barHeight;
  List<RodStackItemsClass> rodItems;

  BarChartRodDataClass({
    required this.barHeight,
    required this.rodItems,
  });
}

class RodStackItemsClass {
  double minY;
  double maxY;
  Color color;

  RodStackItemsClass({
    required this.minY,
    required this.maxY,
    required this.color,
  });
}
