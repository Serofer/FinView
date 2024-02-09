import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fin_view/model/spent.dart';

class SpentDatabase {
    static final SpentDatabase instance = SpentDatabase._init();

    static SpentDatabase? _database;

    SpentDatabase._init();

    Future<Database> get database async {
        if (_database != null) return _databse!;

        _database = await _initDB('spent.db');
        return _database
    }

    Future<Database> _initDB(String filePath) async {
        final dbPath = await getDatabasesPath(); //maybe package path_provider
        final path = join(dbPath, filePath);

        return await openDatabase(path, version: 1, onCreate: _createDB);
    }

    Future _createDB(Database db, int version) async { //https://dart.dev/codelabs/async-await
       final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
       final doubleType = 'NUMERIC NOT NULL';
       final textType = 'TEXT NOT NULL';
       final dateType = 'DATE'; //format: YYY-MM-DD
       
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

        final id = await db.insert(tableExpenditure, note.toJson());
    }

    Future close() async {
        final db = await instance.database;

        db.close();
    }
}