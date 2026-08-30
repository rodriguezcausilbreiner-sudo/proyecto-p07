import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'proveedores_nucleo.dart';

final pasosAcumuladosProvider = StreamProvider.autoDispose<int>((ref) async* {
  final contador = ref.watch(contadorPasosProvider);
  await contador.iniciar();
  yield* contador.acumulado;
});
