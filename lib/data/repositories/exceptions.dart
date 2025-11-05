/// Excepción base para todos los errores de la aplicación.
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// Se lanza cuando hay un error en el servidor (ej. un error de base de datos).
class ServerException extends AppException {
  ServerException(String message) : super('Error del servidor: $message');
}

/// Se lanza cuando no se encuentra un recurso solicitado.
class NotFoundException extends AppException {
  NotFoundException(String resource) : super('No se pudo encontrar: $resource');
}

/// Se lanza cuando hay un error relacionado con la autenticación o permisos.
class AuthException extends AppException {
  AuthException(String message) : super('Error de autenticación: $message');
}