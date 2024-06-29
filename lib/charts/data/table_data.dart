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

    if (tableData == null) {// TODO: add error handling
      throw Exception('Failed to load table data');
    }
  }

  

  
}

class TableData {
  String time;
  Map<String, double> categoryData;

  TableData({
    required this.time,
    required this.categoryData,
  });
}
