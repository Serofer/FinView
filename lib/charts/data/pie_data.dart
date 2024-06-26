import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';

class PieData {
  //add logic to which time period was given
  late List<dynamic> percentages;
  static List<Data> data = [];
  List categoryColors = [
    const Color(0xff0293ee),
    const Color(0xfff8b250),
    const Color(0xff845bef),
    const Color(0xff13d38e)
  ];
  List categories = ['Food', 'Event', 'Education', 'Other'];

  Future<void> calculate(String? timeframe) async {
    data = [];
    for (int i = 0; i < categories.length; i++) {
      data.add(Data(
        name: categories[i],
        percent: 0.0, // You can set any initial value here
        color: categoryColors[i],
      ));
    }
    //calculate percentages
    percentages = await SpentDatabase.instance.calculatePercentages(timeframe);

    for (int i = 0; i < categories.length; i++) {
      data[i] = (Data(
        name: categories[i],
        percent: percentages[i],
        color: categoryColors[i],
      ));
    }
  }
}

class Data {
  final String name;
  final double percent;
  final Color color;

  Data({required this.name, required this.percent, required this.color});
}
