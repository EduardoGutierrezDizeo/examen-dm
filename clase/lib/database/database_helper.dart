import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  factory DatabaseHelper(){
    return instance;
  }

  Future<Database> get database async{
    if(_database != null){
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(), "usuarios.db" );

    return await openDatabase(path, version: 1, onCreate: _createTable);

  }

  Future<void> _createTable (Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre text not null,
      correo text not null,
      edad INTEGER NOT NULL
      )
    ''');
  }
}