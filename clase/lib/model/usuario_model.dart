class UsuarioModel {
  int? id;
  String nombre;
  String correo;
  String edad;

  UsuarioModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.edad,
  });

  factory UsuarioModel.fromJson (Map<String, dynamic> json) {
    return UsuarioModel(
      id: json["id"],
      nombre: json["nombre"],
      correo: json["correo"],
      edad: json["edad"],
    );
  }
}