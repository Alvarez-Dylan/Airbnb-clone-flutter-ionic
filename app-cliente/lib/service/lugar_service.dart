// Peticiones HTTP de lugares. Solo llama a la API y convierte el JSON a modelo.
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../model/lugar_model.dart';
import '../utils/manejar_error.dart';

class LugarService {
  final Dio _dio = ApiConfig.dio;

  Future<List<LugarModel>> buscar(String ciudad) async {
    try {
      // Busqueda simple: solo la ciudad, como dice el enunciado.
      final respuesta = await _dio.post('/lugares/search', data: {'search': ciudad});
      final lista = respuesta.data as List<dynamic>;
      return lista.map((json) => LugarModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw Exception(mensajeDeError(error));
    }
  }

  Future<List<LugarModel>> busquedaAvanzada(Map<String, dynamic> filtros) async {
    try {
      final respuesta = await _dio.post('/lugares/advancedsearch', data: filtros);
      final lista = respuesta.data as List<dynamic>;
      return lista.map((json) => LugarModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw Exception(mensajeDeError(error));
    }
  }

  Future<LugarModel> obtenerLugar(int id) async {
    try {
      final respuesta = await _dio.get('/lugares/$id');
      return LugarModel.fromJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(mensajeDeError(error));
    }
  }
}
