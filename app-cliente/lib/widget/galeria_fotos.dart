// Foto grande + miniaturas. El indice de la foto grande es estado propio de
// este widget (no del lugar ni de ningun provider).
import 'package:flutter/material.dart';

import '../model/lugar_model.dart';
import 'foto_lugar.dart';

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
    if (widget.fotos.isEmpty) {
      return const SizedBox(height: 220, child: FotoLugar(url: null));
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: FotoLugar(url: widget.fotos[_indiceSeleccionado].url),
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: seleccionada
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: FotoLugar(url: widget.fotos[indice].url, radio: 8),
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
