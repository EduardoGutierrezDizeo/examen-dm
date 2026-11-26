import 'package:cuenta/helpers/network_config.dart';
import 'package:mysql_client/mysql_client.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static MySQLConnection? _database;

  DatabaseHelper._init();

  factory DatabaseHelper(){
    return instance;
  }

  Future<MySQLConnection> get database async{
    if(_database != null && _database!.connected){
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<MySQLConnection> _initDatabase() async{
    final conn = await MySQLConnection.createConnection(
      host: "127.0.0.1",
      port: 3306,
      userName: "root",
      password: "root123",
      databaseName: "examen_videojuegos",
      secure: false,
    );

    await conn.connect(timeoutMs: NetworkConfig.connectTimeout.inMilliseconds);
    return conn;
  }
}
