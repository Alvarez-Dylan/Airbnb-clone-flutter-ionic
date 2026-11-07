// Login y registro del cliente. Solo llama a la API; no guarda estado.
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../model/usuario_model.dart';
import '../utils/manejar_error.dart';

class AuthService {
  final Dio _dio = ApiConfig.dio;

  Future<UsuarioModel> iniciarSesion(String email, String password) async {
    try {
      final respuesta = await _dio.post(
        '/cliente/login',
        data: {'email': email, 'password': password},
      );
      return UsuarioModel.fromJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(mensajeDeError(error));
    }
  }

  Future<UsuarioModel> registrar({
    required String nombrecompleto,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      final respuesta = await _dio.post(
        '/cliente/registro',
        data: {
          'nombrecompleto': nombrecompleto,
          'email': email,
          'password': password,
          'telefono': telefono,
        },
      );
      return UsuarioModel.fromJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(mensajeDeError(error));
    }
  }
}
