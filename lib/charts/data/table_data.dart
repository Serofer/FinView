import 'package:flutter/material.dart';

class DataForTable {
  static late List<TableData> tableData;
  List categories = ["Food", "Event", "Eductation", "Other"];

  Future<void> createTableData(String? timeframe) async {
    /*final Map<String, double> fields = Map.fromIterable(categories,
      key: (category) => category,
      value: (_) => 0.0); // Initialize with default value*/ 
    tableData = await SpentDatabase.instance.queryForBar(timeframe, false); 
    print(tableData);
  }

  /*final TableData tableData = TableData(time: '2024-01-27', categoryData: fields);

  // Print the tableData
  print(tableData.categoryData); // Output: {food: 0.0, event: 0.0, education: 0.0, other: 0.0} */
}

class TableData {
    String time;
    Map<String, double> categoryData;

    TableData({
      required this.time,
      required this.categoryData,
    });
  }
