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
    const doubleType = 'NUMERIC NOT NULL';
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
