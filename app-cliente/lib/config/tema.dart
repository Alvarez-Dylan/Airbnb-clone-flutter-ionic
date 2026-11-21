// Estilo centralizado de la app: un solo lugar con el color de marca y las
// formas de botones/campos/tarjetas. Las pantallas usan Theme.of(context) o
// estas constantes en vez de colores escritos a mano (ver CLAUDE.md, Fase E).
import 'package:flutter/material.dart';

// Verde de la bandera de Santa Cruz: identidad propia (varios compañeros
// usan el mismo coral de Airbnb). El dorado es solo para destacar precios.
const colorMarca = Color(0xFF0B6E4F);
const colorAcento = Color(0xFFE9A23B);
const textoSobreAcento = Color(0xFF1D2622);
const colorTextoPrincipal = Color(0xFF1D2622);
const colorTextoSecundario = Color(0xFF66706B);
const _colorFondo = Color(0xFFF6F2EA);

const _radioCampo = 12.0;
const _radioTarjeta = 16.0;
const _altoBoton = 48.0;

ThemeData crearTema() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: colorMarca,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ).copyWith(
    // fromSeed calcula un tono propio a partir de la semilla; se fija el
    // primario exacto para que sea el mismo verde de la bandera, no una
    // variante. El acento (dorado) solo se usa como fondo de precios.
    primary: colorMarca,
    onPrimary: Colors.white,
    tertiary: colorAcento,
    onTertiary: textoSobreAcento,
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
