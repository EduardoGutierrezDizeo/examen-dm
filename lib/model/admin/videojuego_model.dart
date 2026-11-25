class VideojuegoModel {
  final int id;
  final String nombre;
  final String genero;
  final String plataforma;
  final String calificacion;
  final String precio;
  final String desarrolladora;
  final String paisOrigen;
  final String descripcion;
  final String imagen;
  final List<VideojuegoDlc> dlcs;

  const VideojuegoModel({
    required this.id,
    required this.nombre,
    required this.genero,
    required this.plataforma,
    required this.calificacion,
    required this.precio,
    required this.desarrolladora,
    required this.paisOrigen,
    required this.descripcion,
    required this.imagen,
    required this.dlcs,
  });

  factory VideojuegoModel.fromJson(dynamic json) {
    final data = json is Map ? json : const <String, dynamic>{};

    return VideojuegoModel(
      id: _asInt(data['id']),
      nombre: _asString(data['nombre']),
      genero: _asString(data['genero']),
      plataforma: _asString(data['plataforma']),
      calificacion: _asString(data['calificacion']),
      precio: _asString(data['precio']),
      desarrolladora: _asString(data['desarrolladora']),
      paisOrigen: _asString(data['pais_origen']),
      descripcion: _asString(data['descripcion']),
      imagen: _asString(data['imagen']),
      dlcs: _asDlcs(data['dlcs']),
    );
  }
}

class VideojuegoDlc {
  final String nombre;
  final String imagen;

  const VideojuegoDlc({required this.nombre, required this.imagen});

  factory VideojuegoDlc.fromJson(dynamic json) {
    final data = json is Map ? json : const <String, dynamic>{};

    return VideojuegoDlc(
      nombre: _asString(data['nombre']),
      imagen: _asString(data['imagen']),
    );
  }
}

String _asString(dynamic value) => value is String ? value : '';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<VideojuegoDlc> _asDlcs(dynamic value) {
  if (value is! List) return const [];
  return value.map(VideojuegoDlc.fromJson).toList();
}
