import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';

class BarData {
  static int interval = 10; //change according to max bar
  late List<dynamic> dataFromBase;
  static late List<Data> barData;
  String timeframe = "month";

  Future<void> createBarData(timeframe) async {
    barData = await SpentDatabase.instance.queryForBar(timeframe);
  }
  //calculate each Data -> array with values: id, name, color...
}

class Data {
  final int id;
  final String name;
  final double y;
  final Color color;

  const Data({
    required this.id,
    required this.name,
    required this.y,
    required this.color,
  });
}

/*
class Data {
  final int id;
  final String name;
  final BarChartRodData rodData;

  const Data({
    required this.id,
    required this.name,
    required this.rodData,
  });
}

class BarChartRodData {
  final int barHeight;
  final RodStackItems rodItem;

  const BarChartRodData({
    required this.barHeight,
    required this.rodItem,
  });
}

class RodStackItems {
  final double minY;
  final double maxY;
  final Color color;

  const RodStackItems({
    required this.minY,
    required this.maxY,
    required this.color,
  });
}

*/