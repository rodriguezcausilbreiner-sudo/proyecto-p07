import 'package:shared_preferences/shared_preferences.dart';

const _kBase = 'pasos_base';
const _kAcumulado = 'pasos_acumulados';
const _kUltimaLecturaEn = 'pasos_ultima_lectura_epoch_ms';

class AlmacenPasos {
  Future<int> leerBase() async => (await SharedPreferences.getInstance()).getInt(_kBase) ?? 0;
  Future<int> leerAcumulado() async => (await SharedPreferences.getInstance()).getInt(_kAcumulado) ?? 0;

  Future<DateTime?> leerUltimaLecturaEn() async {
    final ms = (await SharedPreferences.getInstance()).getInt(_kUltimaLecturaEn);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> guardar({required int base, required int acumulado}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBase, base);
    await prefs.setInt(_kAcumulado, acumulado);
    await prefs.setInt(_kUltimaLecturaEn, DateTime.now().millisecondsSinceEpoch);
  }
}
