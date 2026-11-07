// Usuario cliente logueado. Lo usan AuthService, AuthProvider y las pantallas de sesion.
class UsuarioModel {
  final int id;
  final String nombrecompleto;
  final String email;
  final String telefono;

  UsuarioModel({
    required this.id,
    required this.nombrecompleto,
    required this.email,
    required this.telefono,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int,
      nombrecompleto: json['nombrecompleto'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombrecompleto': nombrecompleto,
      'email': email,
      'telefono': telefono,
    };
  }
}
