// Punto de entrada de la app cliente: carga la sesion antes de runApp y elige
// la pantalla inicial segun si hay un usuario logueado.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'repository/auth_provider.dart';
import 'repository/busqueda_provider.dart';
import 'repository/reserva_provider.dart';
import 'screen/busqueda_screen.dart';
import 'screen/login_screen.dart';

Future<void> main() async {
  // Necesario porque se usa shared_preferences (un canal de plataforma) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.cargarSesion();

  runApp(BnbClienteApp(authProvider: authProvider));
}

class BnbClienteApp extends StatelessWidget {
  final AuthProvider authProvider;

  const BnbClienteApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => BusquedaProvider()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
      ],
      child: MaterialApp(
        title: 'BNB Cliente',
        // Selectores de fecha y demas textos de Material en espanol.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        locale: const Locale('es'),
        home: authProvider.haySesion ? const BusquedaScreen() : const LoginScreen(),
      ),
    );
  }
}
