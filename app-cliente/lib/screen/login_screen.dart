// Login del cliente. Si funciona, entra directo a la busqueda.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repository/auth_provider.dart';
import 'busqueda_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.iniciarSesion(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (exito) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BusquedaScreen()),
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
      appBar: AppBar(title: const Text('Iniciar sesion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: cargando ? null : _iniciarSesion,
                child: const Text('Iniciar sesion'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistroScreen()),
                ),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
