import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../dominio/entidades/fila_tabla.dart';

/// Conexión de tiempo real a la sala del reto. El servidor rechaza la
/// conexión si el token no es válido (ver `tiempo-real/tabla.js` en la
/// API), así que este cliente nunca debe conectarse sin token.
class SocketRetoDatasource {
  io.Socket? _socket;
  final _controlador = StreamController<List<FilaTabla>>.broadcast();
  Stream<List<FilaTabla>> get tabla => _controlador.stream;

  void conectar({required String baseUrl, required String token}) {
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnectError((err) => _controlador.addError('No se pudo conectar: $err'));
    _socket!.on('tabla:actual', (data) {
      final lista = (data as List).cast<Map>().map((f) => FilaTabla.desdeJson(f.cast<String, dynamic>())).toList();
      _controlador.add(lista);
    });

    _socket!.connect();
  }

  void desconectar() {
    _socket?.disconnect();
    _socket?.dispose();
  }

  void dispose() {
    _controlador.close();
  }
}
