import 'package:cuenta/helpers/api_exception.dart';
import 'package:cuenta/repository/usuario_repositorio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();

  static Future<void> login(String username, String password) async {
    try {
      final id = await UsuarioRepositorio().login(username, password);

      if (id == null) {
        throw const ApiException('Usuario o contraseña incorrectos');
      }

      await _storage.write(key: 'token', value: id.toString());
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.fromDb(e);
    }
  }
}
