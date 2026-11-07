// Registro del cliente. Si funciona, inicia sesion automaticamente y entra a la busqueda.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repository/auth_provider.dart';
import 'busqueda_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.registrar(
      nombrecompleto: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
      telefono: _telefonoController.text,
    );

    if (!mounted) return;

    if (exito) {
      // pushAndRemoveUntil y no pushReplacement: esta pantalla se abrio
      // encima de LoginScreen, asi que hay que sacar toda la pila (si no,
      // queda un boton "atras" que vuelve al login estando ya logueado).
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BusquedaScreen()),
        (ruta) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Ingresa el nombre completo'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (valor) =>
                    (valor == null || valor.trim().isEmpty) ? 'Ingresa el email' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contrasena'),
                obscureText: true,
                validator: (valor) =>
                    (valor == null || valor.isEmpty) ? 'Ingresa la contrasena' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                validator: (valor) =>
                    (valor == null || valor.trim().isEmpty) ? 'Ingresa el telefono' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: cargando ? null : _registrar,
                child: const Text('Registrarse'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Iniciar sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
