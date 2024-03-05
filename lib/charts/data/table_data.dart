import 'package:flutter/material.dart';

class DataForTable {
  static late List<TableData> tableData;

  Future<void> createTableData(String? timeframe) async {
    tableData = await SpentDatabase.instance.queryForBar(timeframe, false); 
  }
}

class TableData {
  //change dynamically on user decision
  String time;
  double food;
  double event;
  double education;
  double other;

  const TableData({
    required this.time,
    required this.food,
    required this.event,
    required this.education,
    required this.other,
  });
}
