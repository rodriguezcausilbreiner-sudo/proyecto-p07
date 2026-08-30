/// El contador de pasos del sistema (Pedometer.stepCountStream) entrega
/// pasos acumulados **desde el último arranque del equipo**, no pasos del
/// día. Si el equipo se reinicia, el valor vuelve a 0. Enviar diferencias
/// sin considerar esto produce números negativos (si se resta ingenuamente)
/// o pérdidas silenciosas (si se descarta el evento).
///
/// Esta clase es lógica pura (sin `pedometer`, sin `SharedPreferences`):
/// recibe primitivos y devuelve primitivos, así que corre en
/// `flutter test` sin dispositivo físico.
///
/// Estado que debe persistirse entre lanzamientos de la app:
/// [ultimaLecturaBase] y [totalAcumulado].
class ResultadoActualizacionPasos {
  final int totalAcumulado;
  final int nuevaBase;
  final int deltaAplicado; // 0 si el incremento fue descartado por RF-06
  final bool seDetectoReinicio;
  final bool seDescartoPorIncrementoImposible;

  const ResultadoActualizacionPasos({
    required this.totalAcumulado,
    required this.nuevaBase,
    required this.deltaAplicado,
    required this.seDetectoReinicio,
    required this.seDescartoPorIncrementoImposible,
  });
}

class CorrectorPasos {
  final int maxPasosPorMinuto;
  const CorrectorPasos({this.maxPasosPorMinuto = 250});

  /// [lecturaActual]: valor crudo que reporta el sensor en este evento
  ///   (pasos desde el arranque del equipo).
  /// [baseAnterior]: última lectura cruda que ya fue contabilizada.
  /// [acumuladoAnterior]: total de pasos del día ya confirmado.
  /// [segundosDesdeUltimaLectura]: para aplicar el límite de 250 pasos/min
  ///   también en el cliente (defensa en profundidad; el servidor vuelve a
  ///   validarlo de forma independiente).
  ResultadoActualizacionPasos actualizar({
    required int lecturaActual,
    required int baseAnterior,
    required int acumuladoAnterior,
    required double segundosDesdeUltimaLectura,
  }) {
    final huboReinicio = lecturaActual < baseAnterior;

    // Delta candidato: si el equipo se reinició, el sensor volvió a
    // contar desde 0, así que el propio valor crudo *es* el delta desde
    // el reinicio. Si no hubo reinicio, el delta es la diferencia normal.
    final deltaCandidato = huboReinicio ? lecturaActual : (lecturaActual - baseAnterior);

    final tasaPorMinuto = segundosDesdeUltimaLectura > 0 ? (deltaCandidato / segundosDesdeUltimaLectura) * 60 : 0;

    final esPlausible = deltaCandidato >= 0 && tasaPorMinuto <= maxPasosPorMinuto + 1e-9;

    // Importante: la nueva base siempre es la lectura cruda actual, tanto
    // si hubo reinicio como si no. Fijarla en 0 tras un reinicio (en vez
    // de en la lectura actual) haría que el próximo delta recontara los
    // pasos ya sumados en este mismo evento — es el error más común al
    // resolver este proyecto.
    final nuevaBase = lecturaActual;

    if (!esPlausible) {
      return ResultadoActualizacionPasos(
        totalAcumulado: acumuladoAnterior,
        nuevaBase: nuevaBase,
        deltaAplicado: 0,
        seDetectoReinicio: huboReinicio,
        seDescartoPorIncrementoImposible: true,
      );
    }

    return ResultadoActualizacionPasos(
      totalAcumulado: acumuladoAnterior + deltaCandidato,
      nuevaBase: nuevaBase,
      deltaAplicado: deltaCandidato,
      seDetectoReinicio: huboReinicio,
      seDescartoPorIncrementoImposible: false,
    );
  }
}
