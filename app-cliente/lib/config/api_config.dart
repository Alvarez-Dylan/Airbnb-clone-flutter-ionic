// Unico lugar con la URL base de la API y el cliente Dio configurado.
// Si la URL del tunel cambia, se actualiza solo aca.
import 'package:dio/dio.dart';

class ApiConfig {
  static const String urlBase = 'https://api.airbnbmob2.online/api';

  // Sin /api: la usan las fotos, que cuelgan de la raiz (ver docs/API.md).
  static const String urlRaiz = 'https://api.airbnbmob2.online';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: urlBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );
}
