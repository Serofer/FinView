import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:fin_view/model/spent.dart';

class SpentDatabase {
  static final SpentDatabase instance = SpentDatabase._init();

  static Database? _database;

  SpentDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expenditure.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); //maybe package path_provider
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
      //print(i.toString());
      sumAmount = spentOnCat[0]['SUM(amount)'] ?? 0;

      //convert always to double:
      if (sumAmount is int) {
        spentCat = sumAmount.toDouble();
      } else {
        spentCat = sumAmount;
      }
      //print('Category: ' + categories[i] + ' ' + spentCat.toString());
      List countAll = await SpentDatabase.instance.readAmount();
      double totAmount = countAll[0]['SUM(amount)'] ?? 0.0;
      double toAdd = (spentCat / totAmount) * 100;
      String percent = toAdd.toStringAsFixed(2);
      double percentNum = double.parse(percent);
      percentages.add(percentNum);
    }

    return percentages;
  }

  Future<List<dynamic>> queryForBar(String timeframe) async {
    late int sections;
    List barData = [];
    final db = await instance.database;
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentWeek = now.week;
    DateTime firstDay = DateTime(currentYear, currentMonth, 1);
    late int timeshift;
    
    int index = 0;
    
  //change variables according to selected timeframe
    if (timeframe == "month")
    {
      final result = await db.rawQuery("SELECT amount, category, date FROM expenditure
      WHERE strftime ('%Y', date) = ? AND strftime('%m', date) = ?", ['$currentYear', '$currentMonth']
      );
      sections = 10;
      timeshift = 3;
    }

    final currentDate = firstDay.add(Duration(days: 3));
    List sectionValues = List.generate(sections, (index) => 0.0);
    //loop over array 10 times and assign a date to each 

    for (int i = 0; i < sections; i++) {
      if (result[i]['date'] < currentDate) {
        sectionValues[index] += result[i]['amount'];
      }
      //add sparation per bar depending on category
      currentDate = currentDate.add(Duration(days: 3));
      barData[index]['id'] = index;
      barData[index]['name'] = "none";
      barData[index]['y'] = sectionValues[index];
      barData[index]['color'] = Color(0xff19bfff);
      index++;

    }
    print(result);
    print(secionValues);
    print(barData);

    return barData;
  }
}
