library;

class SensorPasosNoDisponible implements Exception {
  final String mensaje;
  const SensorPasosNoDisponible([this.mensaje = 'Este equipo no tiene sensor de pasos.']);
  @override
  String toString() => mensaje;
}

class ErrorRed implements Exception {
  final String mensaje;
  const ErrorRed(this.mensaje);
  @override
  String toString() => mensaje;
}

class ErrorConexionTiempoReal implements Exception {
  final String mensaje;
  const ErrorConexionTiempoReal(this.mensaje);
  @override
  String toString() => mensaje;
}
