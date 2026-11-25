import 'package:clase/database/database_helper.dart';
import 'package:clase/model/usuario_model.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioRepositorio {
  Future<int> insertUser(UsuarioModel user) async{
    Database db = await DatabaseHelper().database;
    return await db.insert('usuario', {
      "nombre": user.nombre,
      "correo": user.correo,
      "edad": user.edad
    });
  }

  Future<void> getUser () async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> data = await db.query("usuario");
  }

}