import 'package:dio/dio.dart';
import '../../core/errores/excepciones.dart';

class ApiRetoDatasource {
  final Dio dio;
  const ApiRetoDatasource(this.dio);

  Future<String> obtenerToken({required int usuarioId, required String retoId}) async {
    try {
      final r = await dio.post('/auth/token', data: {'usuarioId': usuarioId, 'retoId': retoId});
      return r.data['token'] as String;
    } on DioException catch (e) {
      throw ErrorRed(_mensajeDe(e));
    }
  }

  Future<void> enviarAporte({
    required String token,
    required String retoId,
    required int usuarioId,
    required int pasos,
  }) async {
    try {
      await dio.post(
        '/retos/$retoId/aportes',
        data: {'usuarioId': usuarioId, 'pasos': pasos},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw ErrorRed(_mensajeDe(e));
    }
  }

  String _mensajeDe(DioException e) {
    if (e.response?.data is Map && e.response?.data['error'] != null) {
      return e.response!.data['error'] as String;
    }
    return e.message ?? 'Error de red desconocido';
  }
}
