import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/entidades/fila_tabla.dart';
import 'proveedores_nucleo.dart';

/// Parámetros de conexión: usuarioId, retoId y token ya obtenido en el
/// login. Se pasa como family porque el socket necesita el token en el
/// momento de conectar, no puede resolverse solo.
final tablaTiempoRealProvider =
    StreamProvider.autoDispose.family<List<FilaTabla>, String>((ref, token) async* {
  final socket = ref.watch(socketRetoProvider);
  socket.conectar(baseUrl: baseUrlApi, token: token);
  yield* socket.tabla;
});
