import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<List<dynamic>> readCategory(String category) async {
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
  }

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
  Future<List<dynamic>> calculatePercentages() async {
    List categories = ['Food', 'Event', 'Education', 'Other'];
    List percentages = [];
    dynamic sumAmount;
    double spentCat = 0.0;
    late List<Expenditure> expenses;
    expenses = await SpentDatabase.instance.readAllExpenditure();
    for (int i = 0; i < categories.length; i++) {
      List<dynamic> spentOnCat =
          await SpentDatabase.instance.readCategory(categories[i]);
      sumAmount = spentOnCat[0]['SUM(amount)'] ?? 0;

      //convert always to double:
      if (sumAmount is int) {
        spentCat = sumAmount.toDouble();
      } else {
        spentCat = sumAmount;
      }
      List countAll = await SpentDatabase.instance.readAmount();
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

  Future<List<Data>> queryForBar(String? timeframe) async {
    //change according to max bar,

    late int dataPerSection;
    List categories = ['Food', 'Event', 'Education', 'Other'];

    List categoryColors = [
      Color(0xff0293ee),
      Color(0xfff8b250),
      Color(0xff845bef),
      Color(0xff13d38e)
    ];
    List<Data> barData = [];
    final db = await instance.database;
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentWeek = now.weekday;
    late DateTime currentDate;
    late List result;
    late int timeshift;
    late int shiftCorrect;
    DateTime firstDay = DateTime(
        currentYear, currentMonth, 1); //change to first day in database
    late int groupedSections;

    int dataIndex = 0;
    //change variables according to selected timeframe
    if (timeframe == "This Month") {
      groupedSections = 4;
      dataPerSection = 3;
      timeshift = 2;
      currentDate = firstDay.add(Duration(days: timeshift));
      shiftCorrect = 1;
      result = await db.rawQuery(
          "SELECT amount, category, date FROM expenditure WHERE strftime ('%Y', date) = ? AND strftime('%m', date) = ?",
          ['$currentYear', '$currentMonth']);
    }
    if (timeframe == "Last 7 days") {
      groupedSections = 7;
      dataPerSection = 1;
      timeshift = 1;
      currentDate = now.subtract(Duration(days: 7));
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

// Query to select data from the last seven days
      result = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE date >= ?",
        [formattedDate],
      );
    }
    if (timeframe == "Last 30 Days") {
      groupedSections = 5;
      dataPerSection = 2;
      timeshift = 3;
      shiftCorrect = 0;
      currentDate = now.subtract(Duration(days: 30));
      print('current date: $currentDate');
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

// Query to select data from the last thirty days
      result = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE date >= ?",
        [formattedDate],
      );
    }
    if (timeframe == "This Year") {
      groupedSections = 12;
      dataPerSection = 3;
      timeshift = 10;
      //shiftCorrect = 1;
      currentDate = DateTime(now.year, 1, 1);
      int currentYear = DateTime.now().year;

// Query to select data for the current year
      result = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE strftime('%Y', date) = ?",
        ['$currentYear'],
      );
    }
    if (timeframe == "All Time") {
      //calculate somehow
      groupedSections = 1;
      dataPerSection = 1;
      timeshift = 0;
      currentDate = firstDay;

      result = await db.rawQuery(
          "SELECT amount, category, date FROM expenditure ORDER BY date ASC");
      print(result);
      print('query all time');
    }
    print(timeframe);
    List sectionValues = List.generate(dataPerSection, (index) => 0.0);

    for (int i = 0; i < groupedSections; i++) {
      List categoryValues = List.generate(categories.length, (index) => 0.0);
      double barHeight = 0.0;
      //define an almost empty listElement of the barData
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
            barHeight = 0;

            double y = 0.0;

            for (int k = 0; k < categories.length; k++) {
              if (categoryValues[k] > 0) {
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
        }
      }
    }
    //List<TableData> table_data = List.generate(sections, (index) => null);

    return barData;
  }
}
