import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentacion/paginas/pagina_reto.dart';

void main() {
  runApp(const ProviderScope(child: AppRetoPasos()));
}

class AppRetoPasos extends StatelessWidget {
  const AppRetoPasos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P7 · Reto de pasos entre fichas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      // Valores de ejemplo: en la app real, usuarioId/fichaId/retoId
      // vendrían de la pantalla de login del sistema de autenticación
      // (reutilizando el patrón de P4) y de la selección del reto activo.
      home: const PaginaReto(usuarioId: 1, fichaId: 1, retoId: '00000000-0000-0000-0000-000000000000'),
    );
  }
}
