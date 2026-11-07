// Foto grande + miniaturas. El indice de la foto grande es estado propio de
// este widget (no del lugar ni de ningun provider).
import 'package:flutter/material.dart';

import '../model/lugar_model.dart';
import '../utils/conversiones.dart';

class GaleriaFotos extends StatefulWidget {
  final List<FotoModel> fotos;

  const GaleriaFotos({super.key, required this.fotos});

  @override
  State<GaleriaFotos> createState() => _GaleriaFotosState();
}

class _GaleriaFotosState extends State<GaleriaFotos> {
  int _indiceSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    // Un lugar puede no tener fotos: nunca se usa fotos[0] sin revisar antes.
    if (widget.fotos.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image, size: 64),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.network(
            urlFoto(widget.fotos[_indiceSeleccionado].url),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 64),
          ),
        ),
        if (widget.fotos.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.fotos.length,
              separatorBuilder: (context, indice) => const SizedBox(width: 8),
              itemBuilder: (context, indice) {
                final seleccionada = indice == _indiceSeleccionado;
                return GestureDetector(
                  onTap: () => setState(() => _indiceSeleccionado = indice),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: seleccionada
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.network(
                      urlFoto(widget.fotos[indice].url),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
