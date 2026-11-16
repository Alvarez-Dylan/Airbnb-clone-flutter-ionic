// Campo de fecha con el mismo estilo de un TextField (usa InputDecorator para
// heredar los colores y bordes de config/tema.dart), pero que abre un DatePicker.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CampoFecha extends StatelessWidget {
  final String etiqueta;
  final DateTime? fecha;
  final DateFormat formato;
  final VoidCallback onTap;

  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.fecha,
    required this.formato,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          fecha == null ? '' : formato.format(fecha!),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
