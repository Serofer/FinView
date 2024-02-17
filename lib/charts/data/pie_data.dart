import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';

class PieData {
  //add logic to which time period was given
  late List<dynamic> percentages;
  static late List<Data> data;

  Future<void> calculate() async {
    percentages = await SpentDatabase.instance.calculatePercentages();

    data = [
      Data(name: 'Food', percent: percentages[0], color: Color(0xff0293ee)),
      Data(name: 'Event', percent: percentages[1], color: Color(0xfff8b250)),
      Data(
          name: 'Education', percent: percentages[2], color: Color(0xff845bef)),
      Data(name: 'Other', percent: percentages[3], color: Color(0xff13d38e)),
    ];
  }
}

class Data {
  final String name;
  final double percent;
  final Color color;

  Data({required this.name, required this.percent, required this.color});
}
