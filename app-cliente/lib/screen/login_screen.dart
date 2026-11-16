// Login del cliente. Si funciona, entra directo a la busqueda.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repository/auth_provider.dart';
import '../widget/encabezado_bnb.dart';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EncabezadoBnb(subtitulo: 'Encuentra dónde quedarte'),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) =>
                        (valor == null || valor.trim().isEmpty) ? 'Ingresa el email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (valor) =>
                        (valor == null || valor.isEmpty) ? 'Ingresa la contraseña' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: cargando ? null : _iniciarSesion,
                    child: const Text('Iniciar sesión'),
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
        ),
      ),
    );
  }
}
