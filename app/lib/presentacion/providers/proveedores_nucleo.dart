import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../datos/datasources/api_reto_datasource.dart';
import '../../datos/datasources/socket_reto_datasource.dart';
import '../../datos/servicios/contador_pasos.dart';

const String baseUrlApi = 'http://10.0.2.2:3000'; // ajustar en dispositivo físico

final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(baseUrl: '$baseUrlApi/api')));

final apiRetoDatasourceProvider = Provider<ApiRetoDatasource>(
  (ref) => ApiRetoDatasource(ref.watch(dioProvider)),
);

/// autoDispose: cancela la suscripción al podómetro al salir de pantalla.
final contadorPasosProvider = Provider.autoDispose<ContadorPasos>((ref) {
  final contador = ContadorPasos();
  ref.onDispose(() {
    contador.detener();
    contador.dispose();
  });
  return contador;
});

final socketRetoProvider = Provider.autoDispose<SocketRetoDatasource>((ref) {
  final socket = SocketRetoDatasource();
  ref.onDispose(() {
    socket.desconectar();
    socket.dispose();
  });
  return socket;
});
