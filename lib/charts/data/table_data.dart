import 'package:fin_view/db/spent_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fin_view/user_data/timeframe_manager.dart';

class DataForTable {
  static late List<TableData> tableData;
  List categories = ["Food", "Event", "Eductation", "Other"];

  Future<void> createTableData(String? timeframe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timeframe = prefs.getString('selectedTimeframe') ?? 'Last 7 Days';
    TimeframeManager().selectedTimeframe = timeframe;
    tableData = await SpentDatabase.instance.queryForBar(timeframe, false);
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
