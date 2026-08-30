import 'package:flutter/material.dart';
import '../../dominio/entidades/fila_tabla.dart';

class TarjetaPosicion extends StatelessWidget {
  final FilaTabla fila;
  final bool esMiFicha;
  const TarjetaPosicion({super.key, required this.fila, this.esMiFicha = false});

  String get _medalla => switch (fila.puesto) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '${fila.puesto}º',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: esMiFicha ? Theme.of(context).colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: SizedBox(width: 36, child: Center(child: Text(_medalla, style: const TextStyle(fontSize: 18)))),
        title: Text(fila.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text('${fila.total} pasos', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
