import 'package:flutter_test/flutter_test.dart';
import 'package:p7_reto_pasos/dominio/servicios/corrector_pasos.dart';

void main() {
  final corrector = CorrectorPasos(maxPasosPorMinuto: 250);

  group('caso normal (sin reinicio)', () {
    test('calcula el delta como la diferencia simple', () {
      final r = corrector.actualizar(
        lecturaActual: 1200,
        baseAnterior: 1000,
        acumuladoAnterior: 500,
        segundosDesdeUltimaLectura: 120,
      );
      expect(r.deltaAplicado, 200);
      expect(r.totalAcumulado, 700);
      expect(r.nuevaBase, 1200);
      expect(r.seDetectoReinicio, false);
    });
  });

  group('reinicio del equipo', () {
    test('detecta el reinicio cuando la lectura cruda cae por debajo de la base', () {
      final r = corrector.actualizar(
        lecturaActual: 50, // el equipo se reinició, el sensor volvió a contar desde 0
        baseAnterior: 8000,
        acumuladoAnterior: 8000,
        segundosDesdeUltimaLectura: 300,
      );
      expect(r.seDetectoReinicio, true);
      expect(r.deltaAplicado, 50, reason: 'la lectura post-reinicio ES el delta, no se resta contra la base vieja');
      expect(r.totalAcumulado, 8050, reason: 'lo acumulado antes del reinicio se conserva');
    });

    test('la nueva base es la lectura actual, no 0, para no recontar en el siguiente evento', () {
      final primero = corrector.actualizar(
        lecturaActual: 50,
        baseAnterior: 8000,
        acumuladoAnterior: 8000,
        segundosDesdeUltimaLectura: 300,
      );
      // Si la base quedara en 0, este segundo evento sumaría 80 pasos
      // completos otra vez en vez de un delta de 30.
      final segundo = corrector.actualizar(
        lecturaActual: 80,
        baseAnterior: primero.nuevaBase,
        acumuladoAnterior: primero.totalAcumulado,
        segundosDesdeUltimaLectura: 30,
      );
      expect(primero.nuevaBase, 50);
      expect(segundo.deltaAplicado, 30);
      expect(segundo.totalAcumulado, 8080);
    });
  });

  group('incrementos imposibles (RF-06, defensa en cliente)', () {
    test('descarta un delta que implica más de 250 pasos/min', () {
      final r = corrector.actualizar(
        lecturaActual: 6000,
        baseAnterior: 1000,
        acumuladoAnterior: 1000,
        segundosDesdeUltimaLectura: 60, // 5000 pasos en 1 minuto: imposible
      );
      expect(r.seDescartoPorIncrementoImposible, true);
      expect(r.deltaAplicado, 0);
      expect(r.totalAcumulado, 1000, reason: 'el acumulado no debe cambiar si se descarta el evento');
    });

    test('acepta un delta alto si el tiempo transcurrido lo justifica', () {
      final r = corrector.actualizar(
        lecturaActual: 6000,
        baseAnterior: 1000,
        acumuladoAnterior: 1000,
        segundosDesdeUltimaLectura: 3600, // 5000 pasos en 1 hora: razonable
      );
      expect(r.seDescartoPorIncrementoImposible, false);
      expect(r.totalAcumulado, 6000);
    });
  });
}
