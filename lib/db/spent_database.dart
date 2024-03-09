import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fin_view/charts/data/table_data.dart';
//import 'package:fin_view/charts/data/table_data.dart';

class SpentDatabase {
  static final SpentDatabase instance = SpentDatabase._init();

  static Database? _database;

  SpentDatabase._init();

  //Beginning of database functions

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expenditure.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    //https://dart.dev/codelabs/async-await
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const doubleType = 'DECIMAL(10, 2) NOT NULL';
    const textType = 'TEXT NOT NULL';
    const dateType = 'DATE'; //format: YYY-MM-DD

    await db.execute('''
            CREATE TABLE $tableExpenditure (
                ${ExpenditureFields.id} $idType,
                ${ExpenditureFields.amount} $doubleType,
                ${ExpenditureFields.category} $textType,
                ${ExpenditureFields.date} $dateType
            )
        ''');
  }

  Future<Expenditure> create(Expenditure expenditure) async {
    final db = await instance.database;

    /*final json = expenditure.toJson();
    final columns =
        '${ExpenditureFields.amount}, ${ExpenditureFields.category}, ${ExpenditureFields.date}';
    final values =
        '${json[ExpenditureFields.amount]}, ${json[ExpenditureFields.category]}, ${json[ExpenditureFields.date]}';

    final id = await db.rawInsert('INSERT INTO $tableExpenditure ($columns) VALUES ($values)');*/

    final id = await db.insert(tableExpenditure, expenditure.toJson());
    return expenditure.copy(id: id);
  }

  Future<Expenditure> readExpenditure(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableExpenditure,
      columns: ExpenditureFields.values,
      where: '${ExpenditureFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expenditure.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Expenditure>> readAllExpenditure() async {
    final db = await instance.database;

    //final result = await db.query(
    //  'SELECT * FROM $tableExpenditure ORDER BY ${ExpenditureFields.date} ASC');

    final result = await db.query(tableExpenditure,
        orderBy: '${ExpenditureFields.date} DESC');

    return result.map((json) => Expenditure.fromJson(json)).toList();
  }

  /*Future<List<dynamic>> readCategory(String category) async {
    final db = await instance.database;

    final List spentOnCat = await db.rawQuery(
        "SELECT SUM(amount) FROM expenditure WHERE category = '$category'");

    return spentOnCat;
  }

  Future<List<dynamic>> readAmount() async {
    final db = await instance.database;

    final List tot_amount =
        await db.rawQuery("SELECT SUM(amount) FROM expenditure");

    return tot_amount;
  }*/

  Future<int> update(Expenditure expenditure) async {
    final db = await instance.database;

    return db.update(
      tableExpenditure,
      expenditure.toJson(),
      where: '${ExpenditureFields.id} = ?',
      whereArgs: [expenditure.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableExpenditure,
      where: '${ExpenditureFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await instance.database;

    return await db.delete(tableExpenditure);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

//calculate percentages
//has to access the selected timeframe, during IFASS
  Future<List<dynamic>> calculatePercentages(String? timeframe) async {
    final db = await instance.database;
    List categories = ['Food', 'Event', 'Education', 'Other'];
    List percentages = [];
    dynamic sumAmount;
    double spentCat = 0.0;
    late List<Expenditure> expenses;
    late List spentOnCat;
    late DateTime timefilter;
    expenses = await SpentDatabase.instance.readAllExpenditure();

    for (int i = 0; i < categories.length; i++) {
      switch (timeframe) {
        case 'Last 7 Days':
          // Get data from the last seven days
          timefilter = DateTime.now()
              .subtract(Duration(days: 7))
              .subtract(Duration(seconds: 1));
          break;
        case 'Last 30 Days':
          // Get data from the last thirty days
          DateTime thirtyDaysAgo = DateTime.now()
              .subtract(Duration(days: 30))
              .subtract(Duration(seconds: 1));

          List spentOnCat = await db.rawQuery(
              "SELECT SUM(amount) FROM expenditure WHERE category = '$categories[i]' AND date >= ?",
              [thirtyDaysAgo.toIso8601String()]);
          break;
        case 'This Month':
          // Get data for the current month
          int currentYear = DateTime.now().year;
          int currentMonth = DateTime.now().month;
          String timefilterString =
              '$currentYear-${currentMonth.toString().padLeft(2, '0')}-01';
          DateTime timefilter = DateTime.parse(timefilterString); //maybe bug
          break;
        case 'This Year':
          // Get data for the current year
          int currentYear = DateTime.now().year;
          String timefilterString = '$currentYear-01-01';
          DateTime timefilter = DateTime.parse(timefilterString);
          break;
        case 'All Time':
          // Get all data
          DateTime now = DateTime.now();
          timefilter = DateTime(now.year - 100, now.month, now.day);

          break;
        default:
          // Invalid timeframe
          throw ArgumentError('Invalid timeframe: $timeframe');
      }

      spentOnCat = await db.rawQuery(
          "SELECT SUM(amount) FROM expenditure WHERE category = '$categories[i]' AND date >= ?",
          [timefilter.toIso8601String()]);

      //List<dynamic> spentOnCat =
      //await SpentDatabase.instance.readCategory(categories[i]);
      sumAmount = spentOnCat[0]['SUM(amount)'] ?? 0;

      //convert always to double:
      if (sumAmount is int) {
        spentCat = sumAmount.toDouble();
      } else {
        spentCat = sumAmount;
      }
      //List countAll = await SpentDatabase.instance.readAmount();
      final List countAll = await db.rawQuery(
          "SELECT SUM(amount) FROM expenditure WHERE date >= ?",
          [timefilter.toIso8601String()]);

      double totalAmount = countAll[0]['SUM(amount)'] is int
          ? (countAll[0]['SUM(amount)'] as int).toDouble()
          : countAll[0]['SUM(amount)'];
      double totAmount = totalAmount ?? 0.0;
      double toAdd = (spentCat / totAmount) * 100;
      String percent = toAdd.toStringAsFixed(2);
      double percentNum = double.parse(percent);
      percentages.add(percentNum);
    }

    return percentages;
  }

  Future<dynamic> queryForBar(String? timeframe, bool bar) async {
    late int dataPerSection;
    List categories = ['Food', 'Event', 'Education', 'Other'];
    List categoriesExtra = categories.toList();
    categoriesExtra.add('Total');
    List totalCategoryValues = List.generate(categories.length, (index) => 0.0);

    List categoryColors = [
      Color(0xff0293ee),
      Color(0xfff8b250),
      Color(0xff845bef),
      Color(0xff13d38e)
    ];
    List<Data> barData = [];
    Map<String, dynamic> timeData = {};
    final db = await instance.database; //delete unnecessary stuff
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentWeek = now.weekday;

    late DateTime currentDate;
    late List result;
    late int timeshift;
    late int shiftCorrect;
    late int groupedSections;
    int dataIndex = 0;
    print(timeframe);

    timeData = await getTimeData(timeframe);

    groupedSections = timeData['groupedSections'];
    dataPerSection = timeData['dataPerSection'];
    timeshift = timeData['timeshift'];
    shiftCorrect = timeData['shiftCorrect'];
    currentDate = timeData['currentDate']; //maybe change dataType
    result = timeData['result'];

    //List sectionValues =
    //List.generate(timeData['dataPerSection'], (index) => 0.0);

    List<TableData> tableData = List.generate(groupedSections + 1, (index) {
      // Generate TableData for each index
      return TableData(
        time: '',
        categoryData: Map.fromIterable(categoriesExtra,
            key: (category) => category,
            value: (_) => 0.0), // Initialize with default value
      );
    });

    for (int i = 0; i < groupedSections; i++) {
      List categoryValues = List.generate(categories.length, (index) => 0.0);

      double total = 0.0;
      double barHeight = 0.0;

      //define an almost empty listElement of the barData
      tableData[i].time = 'Week ${i.toString()}';
      barData.add(Data(
        id: i,
        name: 'Week ${i.toString()}',
        rodData: List.generate(
          dataPerSection,
          (index) => BarChartRodDataClass(
            barHeight: 0.0,
            rodItems: List.generate(
              categories.length,
              (index) => RodStackItemsClass(
                minY: 0.0,
                maxY: 0.0,
                color: Color(0xff19bfff),
              ),
            ),
          ),
        ),
      ));

      for (int j = 0; j < dataPerSection; j++) {
        //define some variables
        var thisData = new Map();
        late var nextData;
        late DateTime nextDate;

        //check if data is still available
        if (dataIndex < result.length) {
          thisData = result[dataIndex];
        } else {
          break;
        }
        if (dataIndex < result.length - 1) {
          nextData = new Map();
          nextData = result[dataIndex + 1];
          nextDate = DateTime.parse(nextData['date']);
          nextDate = nextDate.add(const Duration(seconds: 1));
        } else {
          nextDate = DateTime.now();
        }

        DateTime dateFromDatabase = DateTime.parse(thisData['date']);
        dateFromDatabase = dateFromDatabase.add(const Duration(seconds: 1));

        if (dateFromDatabase.isBefore(currentDate)) {
          barHeight += thisData['amount'];
          categoryValues[categories.indexOf(thisData['category'])] +=
              thisData['amount'];
          j--;

          //this is wrong
          if (nextDate.isAfter(currentDate)) {
            print(dateFromDatabase);
            print(currentDate);
            j++;
            barData[i].rodData[j].barHeight = barHeight;

            barHeight = 0.0;

            double y = 0.0;

            for (int k = 0; k < categories.length; k++) {
              if (categoryValues[k] > 0) {
                tableData[i].categoryData[categories[i]] = categoryValues[k];
                total += categoryValues[k];
                totalCategoryValues[k] += categoryValues[k];
                //tableData[i][categories[k]] = categoryValues[k];//set the key and value for table
                //set the rodItems
                barData[i].rodData[j].rodItems[k].minY = y;
                y += categoryValues[k];
                barData[i].rodData[j].rodItems[k].maxY = y;
                barData[i].rodData[j].rodItems[k].color = categoryColors[k];
                //reset the categoryValues
                categoryValues[k] = 0.0;
              }
            }

            currentDate = currentDate.add(Duration(days: timeshift));
            if (j == dataPerSection - 2) {
              currentDate = currentDate.add(Duration(days: shiftCorrect));
            }
          }

          dataIndex++;
        } else {
          //if the data is after the current date
          currentDate = currentDate.add(Duration(days: timeshift));
          if (j == dataPerSection - 2) {
            currentDate = currentDate.add(Duration(days: shiftCorrect));
          }
          tableData[i].categoryData['Total'] = total;
        }
      }
    }
    double allAdded = 0.0;
    tableData[groupedSections].time = 'All';
    for (int i = 0; i < categories.length; i++) {
      tableData[groupedSections].categoryData[categories[i]] =
          totalCategoryValues[i];
      allAdded += totalCategoryValues[i];
    }

    tableData[groupedSections].categoryData['Total'] = allAdded;
    //assign the total values in the tableData
    //tableData[gropuedSections].categoryValues['Food'] =
    //List<TableData> table_data = List.generate(sections, (index) => null);
    if (bar) {
      return barData;
    } else {
      return tableData;
    }
  }

  /*Future<List<TableData>> queryForTable(String? timeframe) async {
    Map<String, dynamic> timeData = {};

    List<TableData> tableData = [];

    late DateTime currentDate;
    late List result;
    late int timeshift;
    late int shiftCorrect;
    late int groupedSections;
    int dataIndex = 0;
    
    timeData = getTimeData(timeframe);

    groupedSections = timeData['groupedSections'];
    dataPerSection = timeData['dataPerSection'];
    timeshift = timeData['timeshift'];
    shiftCorrect = timeData['shiftCorrect'];
    currentDate = timeData['currentDate']; //maybe change dataType
    result = timeData['result'];

    //all the logic


    return tableData;
  }*/

  Future<Map<String, dynamic>> getTimeData(String? timeframe) async {
    Map<String, dynamic> timeData = {};
    final db = await instance.database;

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentWeek = now.weekday;
    late DateTime currentDate;
    timeData['shiftCorrect'] = 0;

    if (timeframe == "All Time") {
      //calculate somehow
      timeData['groupedSections'] = 1;
      timeData['dataPerSection'] = 1;
      timeData['timeshift'] = 0;

      timeData['result'] = await db.rawQuery(
          "SELECT amount, category, date FROM expenditure ORDER BY date ASC");
      timeData['currentDate'] = timeData['result'][0]['date'];
      currentDate = timeData['currentDate'];

      DateTime sevenDays = now.subtract(Duration(days: 7));
      DateTime thisMonth = DateTime(currentYear, currentMonth, 1);
      int targetMonth = currentMonth - 3;
      int targetYear = currentYear;
      int startYear = currentDate.year;
      int years = currentYear - startYear;

      if (targetMonth < 1) {
        targetMonth += 12; // Wrap around to December of the previous year
        targetYear -= 1; // Adjust the year
      }
      DateTime threeMonths = DateTime(targetYear, targetMonth, 1);

      if (currentDate.isAfter(sevenDays)) {
        timeframe = "Last 7 Days";
      } else if (currentDate.isAfter(thisMonth)) {
        timeframe = "This Month";
      } else if (currentDate.isAfter(threeMonths)) {
        timeData['groupedSections'] = 12;
        timeData['dataPerSection'] = 1;
        timeData['timeshift'] = 3;
      } else if (years == 0) {
        timeframe = "This Year";
      } else {
        timeData['groupedSections'] = years * 12;
        timeData['dataPerSection'] = 3;
        timeData['timeshift'] = 10;
        timeData['shiftCorrect'] = 0;
      }

      print(timeData['result']);
      print('query all time');
    }
    if (timeframe == "This Month") {
      timeData['groupedSections'] = 4;
      timeData['dataPerSection'] = 3;
      timeData['timeshift'] = 2;
      timeData['currentDate'] = DateTime(currentYear, currentMonth, 1);
      timeData['shiftCorrect'] = 1;
      timeData['result'] = await db.rawQuery(
          "SELECT amount, category, date FROM expenditure WHERE strftime ('%Y', date) = ? AND strftime('%m', date) = ?",
          ['$currentYear', '$currentMonth']);
    }
    if (timeframe == "Last 7 Days") {
      timeData['groupedSections'] = 7;
      timeData['dataPerSection'] = 1;
      timeData['timeshift'] = 1;
      timeData['currentDate'] = now.subtract(Duration(days: 7));
      currentDate = timeData['currentDate'];
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

// Query to select data from the last seven days
      timeData['result'] = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE date >= ?",
        [formattedDate],
      );
    }
    if (timeframe == "Last 30 Days") {
      timeData['groupedSections'] = 5;
      timeData['dataPerSection'] = 2;
      timeData['timeshift'] = 3;
      timeData['currentDate'] = now.subtract(Duration(days: 30));
      currentDate = timeData['currentDate'];
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

// Query to select data from the last thirty days
      timeData['result'] = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE date >= ?",
        [formattedDate],
      );
    }
    if (timeframe == "This Year") {
      timeData['groupedSections'] = 12;
      timeData['dataPerSection'] = 3;
      timeData['timeshift'] = 10;
      //shiftCorrect = 1;
      timeData['currentDate'] = DateTime(now.year, 1, 1);
      int currentYear = DateTime.now().year;

// Query to select data for the current year
      timeData['result'] = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE strftime('%Y', date) = ?",
        ['$currentYear'],
      );
    }
    return timeData;
  }
}
