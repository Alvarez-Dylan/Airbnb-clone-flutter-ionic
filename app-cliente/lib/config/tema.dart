// Estilo centralizado de la app: un solo lugar con el color de marca y las
// formas de botones/campos/tarjetas. Las pantallas usan Theme.of(context) o
// estas constantes en vez de colores escritos a mano (ver CLAUDE.md, Fase E).
import 'package:flutter/material.dart';

const colorMarca = Color(0xFFE8505B);
const colorTextoPrincipal = Color(0xFF222222);
const colorTextoSecundario = Color(0xFF717171);
const _colorFondo = Color(0xFFF7F7F7);

const _radioCampo = 12.0;
const _radioTarjeta = 16.0;
const _altoBoton = 48.0;

ThemeData crearTema() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: colorMarca,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _colorFondo,
    textTheme: Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(bodyColor: colorTextoPrincipal, displayColor: colorTextoPrincipal),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: colorTextoPrincipal,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(_radioCampo)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Ancho minimo fijo (no Size.fromHeight, que es ancho infinito): un
        // boton dentro de un Row sin Expanded (ej. BarraReservar) pediria
        // ancho infinito y Flutter tira "BoxConstraints forces an infinite
        // width". Los botones que ocupan todo el ancho (Column con
        // crossAxisAlignment.stretch) igual quedan iguales: el stretch ya
        // los estira sin importar este minimo.
        minimumSize: const Size(64, _altoBoton),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radioCampo)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        // Ancho minimo fijo (no Size.fromHeight, que es ancho infinito): un
        // boton dentro de un Row sin Expanded (ej. BarraReservar) pediria
        // ancho infinito y Flutter tira "BoxConstraints forces an infinite
        // width". Los botones que ocupan todo el ancho (Column con
        // crossAxisAlignment.stretch) igual quedan iguales: el stretch ya
        // los estira sin importar este minimo.
        minimumSize: const Size(64, _altoBoton),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radioCampo)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radioTarjeta)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
      labelStyle: TextStyle(color: colorTextoPrincipal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radioCampo)),
    ),
  );
}
