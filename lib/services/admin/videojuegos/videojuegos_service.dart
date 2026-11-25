import 'package:cuenta/helpers/api_exception.dart';
import 'package:cuenta/model/admin/videojuego_model.dart';
import 'package:cuenta/repository/videojuego_repositorio.dart';

class VideojuegosService {
  static Future<List<VideojuegoModel>> getVideojuegos() async {
    try {
      return await VideojuegoRepositorio().getVideojuegos();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.fromDb(e);
    }
  }

  static Future<VideojuegoModel> getDetail(String id) async {
    final videojuegoId = int.tryParse(id);

    if (videojuegoId == null) {
      throw const ApiException('Videojuego no encontrado', statusCode: 404);
    }

    try {
      final videojuego = await VideojuegoRepositorio().getVideojuego(
        videojuegoId,
      );

      if (videojuego == null) {
        throw const ApiException('Videojuego no encontrado', statusCode: 404);
      }

      return videojuego;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.fromDb(e);
    }
  }
}
