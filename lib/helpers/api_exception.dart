class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDb(Object error) {
    final texto =
        '${error.runtimeType.toString()} ${error.toString()}'.toLowerCase();
    final esConexion = texto.contains('socketexception') ||
        texto.contains('connection') ||
        texto.contains('timeout') ||
        texto.contains('failed host lookup') ||
        texto.contains('connection refused') ||
        texto.contains('network is unreachable');

    if (esConexion) {
      return const ApiException(
        'No se pudo conectar con la base de datos. Verifica que MySQL (XAMPP) esté encendido.',
      );
    }

    return const ApiException('Ocurrió un error al consultar la base de datos.');
  }

  @override
  String toString() => message;
}
