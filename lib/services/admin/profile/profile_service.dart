import 'package:cuenta/helpers/api_exception.dart';
import 'package:cuenta/model/usuario_model.dart';
import 'package:cuenta/repository/usuario_repositorio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  static final _storage = FlutterSecureStorage();

  Future<UsuarioModel> getProfile() async {
    final token = await _storage.read(key: 'token') ?? '';
    final id = int.tryParse(token);

    if (id == null) {
      throw const ApiException('Sesión inválida, vuelve a iniciar sesión.');
    }

    try {
      final usuario = await UsuarioRepositorio().getUsuario(id);

      if (usuario == null) {
        throw const ApiException('No se encontró el usuario.');
      }

      return usuario;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.fromDb(e);
    }
  }
}
