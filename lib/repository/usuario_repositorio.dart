import 'package:cuenta/database/database_helper.dart';
import 'package:cuenta/model/usuario_model.dart';

class UsuarioRepositorio {
  Future<int?> login(String username, String password) async {
    final db = await DatabaseHelper().database;
    final result = await db.execute(
      'SELECT id FROM usuario WHERE username = :username AND password = SHA2(:password, 256)',
      {'username': username, 'password': password},
    );

    if (result.rows.isEmpty) return null;
    return int.tryParse(result.rows.first.colByName('id') ?? '');
  }

  Future<UsuarioModel?> getUsuario(int id) async {
    final db = await DatabaseHelper().database;
    final result = await db.execute(
      'SELECT id, username, email, nombre, apellido, telefono, ciudad FROM usuario WHERE id = :id',
      {'id': id},
    );

    if (result.rows.isEmpty) return null;
    return UsuarioModel.fromJson(result.rows.first.assoc());
  }
}
