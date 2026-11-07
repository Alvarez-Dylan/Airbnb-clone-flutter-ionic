// Estado de la sesion del cliente (ChangeNotifier, igual que los practicos 3 y 4).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/usuario_model.dart';
import '../service/auth_service.dart';

const _claveSesion = 'sesionCliente';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UsuarioModel? _usuario;
  bool _cargando = false;
  String? _error;

  UsuarioModel? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get haySesion => _usuario != null;

  Future<void> cargarSesion() async {
    final preferencias = await SharedPreferences.getInstance();
    final guardado = preferencias.getString(_claveSesion);
    if (guardado != null) {
      _usuario = UsuarioModel.fromJson(jsonDecode(guardado) as Map<String, dynamic>);
    }
  }

  Future<bool> iniciarSesion(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuario = await _authService.iniciarSesion(email, password);
      await _guardarSesion();
      _cargando = false;
      notifyListeners();
      return true;
    } catch (error) {
      _error = _sinPrefijoException(error);
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar({
    required String nombrecompleto,
    required String email,
    required String password,
    required String telefono,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.registrar(
        nombrecompleto: nombrecompleto,
        email: email,
        password: password,
        telefono: telefono,
      );
      // Registro exitoso: inicia sesion automatico con el mismo email y
      // contrasena (asi lo muestran los wireframes, ver CLAUDE.md).
      _usuario = await _authService.iniciarSesion(email, password);
      await _guardarSesion();
      _cargando = false;
      notifyListeners();
      return true;
    } catch (error) {
      _error = _sinPrefijoException(error);
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    _usuario = null;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_claveSesion);
    notifyListeners();
  }

  Future<void> _guardarSesion() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_claveSesion, jsonEncode(_usuario!.toJson()));
  }

  String _sinPrefijoException(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
