class UsuarioModel {
  final int id;
  final String username;
  final String email;
  final String nombre;
  final String apellido;
  final String telefono;
  final String ciudad;

  const UsuarioModel({
    required this.id,
    required this.username,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.ciudad,
  });

  factory UsuarioModel.fromJson(dynamic json) {
    final data = json is Map ? json : const <String, dynamic>{};

    return UsuarioModel(
      id: _asInt(data['id']),
      username: _asString(data['username']),
      email: _asString(data['email']),
      nombre: _asString(data['nombre']),
      apellido: _asString(data['apellido']),
      telefono: _asString(data['telefono']),
      ciudad: _asString(data['ciudad']),
    );
  }

  String get fullName => '$nombre $apellido'.trim();
}

String _asString(dynamic value) => value is String ? value : '';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
