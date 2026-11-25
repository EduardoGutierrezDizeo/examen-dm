import 'package:cuenta/database/database_helper.dart';
import 'package:cuenta/model/admin/videojuego_model.dart';

class VideojuegoRepositorio {
  Future<List<VideojuegoModel>> getVideojuegos() async {
    final db = await DatabaseHelper().database;
    final result = await db.execute('SELECT * FROM videojuego ORDER BY nombre');

    return result.rows.map((row) => VideojuegoModel.fromJson(row.assoc())).toList();
  }

  Future<VideojuegoModel?> getVideojuego(int id) async {
    final db = await DatabaseHelper().database;
    final result = await db.execute(
      'SELECT * FROM videojuego WHERE id = :id',
      {'id': id},
    );

    if (result.rows.isEmpty) return null;

    final fila = Map<String, dynamic>.from(result.rows.first.assoc());
    final dlcs = await db.execute(
      'SELECT nombre, imagen FROM dlc WHERE videojuego_id = :id ORDER BY id',
      {'id': id},
    );
    fila['dlcs'] = dlcs.rows.map((row) => row.assoc()).toList();

    return VideojuegoModel.fromJson(fila);
  }
}
