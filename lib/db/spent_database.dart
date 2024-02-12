import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:fin_view/model/spent.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;


  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() asnyc {
    Directory documentsDirectory = await getApplicationDocumentsDirectory(); 
    String path = join(documentsDirectory.path, 'expenses.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate, );
  }

  Future _onCreate(Database db, int version) async {
    //Date has the format: YYYY-MM-DD
    await db.execute('''
      CREATE table expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount NUMERIC NOT NULL,
        category TEXT NOT NULL,
        date DATE 
      )
    ''');
  }
  Future<List<Expenditure>> getExpenses() async {
    Database db = await instance.database;
    var expenses = await db.query('expenses', orderBy: 'date');
    List<Expenditure> expensesList = expenses.isNotEmpty ? expenses.map((c) => Expenditure.fromMap(c)).toList() : [];
    return expensesList;
  }

  Future<int> add(Expenditure expenditure) async {
    Database db = await instance.databse;
    return await db.insert('expenses', expenditure.toMap());
  }

 /* Future<int> remove(int id) async {
    Dat
  }*/

}

/*
  Future _createDB(Database db, int version) async {
    //https://dart.dev/codelabs/async-await
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const doubleType = 'NUMERIC NOT NULL';
    const textType = 'TEXT NOT NULL';
    const dateType = 'DATE'; //format: YYYY-MM-DD

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

    final result = await db.query(
        'SELECT * FROM $tableExpenditure ORDER BY ${ExpenditureFields.date} ASC');

    //final result = await db.query(tableExpenditure,
    // orderBy: '${ExpenditureFields.date} ASC');

    return result.map((json) => Expenditure.fromJson(json)).toList();
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

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
*/