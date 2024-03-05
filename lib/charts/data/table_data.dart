import 'package:flutter/material.dart';

class DataForTable {
  static late List<TableData> tableData;

  Future<void> createTableData(String? timeframe) async {
    tableData = await SpentDatabase.instance.queryForTable(timeframe);
  }
}

class TableData {
  //change dynamically on user decision
  final String time;
  final double food;
  final double event;
  final double education;
  final double other;

  const TableData({
    required this.time,
    required this.food,
    required this.event,
    required this.education,
    required this.other,
  });
}
