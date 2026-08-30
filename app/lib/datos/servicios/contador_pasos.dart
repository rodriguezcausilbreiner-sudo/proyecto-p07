import 'dart:async';
import 'package:pedometer/pedometer.dart';
import '../../core/errores/excepciones.dart';
import '../../dominio/servicios/corrector_pasos.dart';
import 'almacen_pasos.dart';

/// Conecta `Pedometer.stepCountStream` (dato crudo del sensor del
/// sistema) con [CorrectorPasos] (lógica pura ya probada) y persiste el
/// estado en [AlmacenPasos] para sobrevivir al cierre de la app —no solo
/// al reinicio del equipo.
class ContadorPasos {
  final CorrectorPasos corrector;
  final AlmacenPasos almacen;
  StreamSubscription<StepCount>? _sub;

  final _controlador = StreamController<int>.broadcast(); // emite el total acumulado
  Stream<int> get acumulado => _controlador.stream;

  ContadorPasos({CorrectorPasos? corrector, AlmacenPasos? almacen})
      : corrector = corrector ?? const CorrectorPasos(),
        almacen = almacen ?? AlmacenPasos();

  Future<void> iniciar() async {
    try {
      _sub = Pedometer.stepCountStream.listen(_procesar, onError: (_) {
        throw const SensorPasosNoDisponible();
      });
    } catch (_) {
      throw const SensorPasosNoDisponible();
    }
  }

  Future<void> _procesar(StepCount evento) async {
    final baseAnterior = await almacen.leerBase();
    final acumuladoAnterior = await almacen.leerAcumulado();
    final ultimaLecturaEn = await almacen.leerUltimaLecturaEn();

    final segundos = ultimaLecturaEn == null ? 0.0 : DateTime.now().difference(ultimaLecturaEn).inMilliseconds / 1000;

    final resultado = corrector.actualizar(
      lecturaActual: evento.steps,
      baseAnterior: baseAnterior,
      acumuladoAnterior: acumuladoAnterior,
      segundosDesdeUltimaLectura: segundos,
    );

    await almacen.guardar(base: resultado.nuevaBase, acumulado: resultado.totalAcumulado);
    _controlador.add(resultado.totalAcumulado);
  }

  Future<void> detener() async {
    await _sub?.cancel();
  }

  void dispose() {
    _controlador.close();
  }
}
