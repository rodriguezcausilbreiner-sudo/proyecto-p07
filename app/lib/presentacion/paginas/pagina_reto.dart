import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_pasos.dart';
import '../providers/provider_tabla.dart';
import '../providers/proveedores_nucleo.dart';
import '../widgets/tarjeta_posicion.dart';

class PaginaReto extends ConsumerStatefulWidget {
  final int usuarioId;
  final int fichaId;
  final String retoId;

  const PaginaReto({super.key, required this.usuarioId, required this.fichaId, required this.retoId});

  @override
  ConsumerState<PaginaReto> createState() => _PaginaRetoState();
}

class _PaginaRetoState extends ConsumerState<PaginaReto> {
  String? _token;
  String? _error;
  int _ultimoPasosEnviados = 0;

  @override
  void initState() {
    super.initState();
    _autenticar();
  }

  Future<void> _autenticar() async {
    try {
      final token = await ref
          .read(apiRetoDatasourceProvider)
          .obtenerToken(usuarioId: widget.usuarioId, retoId: widget.retoId);
      if (!mounted) return;
      setState(() => _token = token);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _reportarSiCorresponde(int totalActual) async {
    final token = _token;
    if (token == null) return;
    // RF-03: se envía el acumulado "por horas" en producción (con un
    // Timer.periodic); aquí se reporta cada vez que el acumulado cambia
    // lo suficiente, para que la demo en clase sea visible de inmediato.
    if (totalActual - _ultimoPasosEnviados < 10) return;
    _ultimoPasosEnviados = totalActual;
    try {
      await ref.read(apiRetoDatasourceProvider).enviarAporte(
            token: token,
            retoId: widget.retoId,
            usuarioId: widget.usuarioId,
            pasos: totalActual,
          );
    } catch (_) {
      // La cola de reintento queda como extensión (ver README); por ahora
      // el próximo cambio de acumulado reintentará el envío.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pasosAsync = ref.watch(pasosAcumuladosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('P7 · Reto de pasos entre fichas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: pasosAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Sensor de pasos no disponible: $e', style: const TextStyle(color: Colors.red)),
              data: (total) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _reportarSiCorresponde(total));
                return Column(
                  children: [
                    Text('$total', style: Theme.of(context).textTheme.displayMedium),
                    const Text('pasos hoy'),
                  ],
                );
              },
            ),
          ),
          if (_error != null) Padding(padding: const EdgeInsets.all(8), child: Text(_error!)),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Tabla de posiciones en vivo', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _token == null
                ? const Center(child: CircularProgressIndicator())
                : Consumer(
                    builder: (context, ref, _) {
                      final tablaAsync = ref.watch(tablaTiempoRealProvider(_token!));
                      return tablaAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Sin conexión en tiempo real: $e')),
                        data: (tabla) => ListView.builder(
                          itemCount: tabla.length,
                          itemBuilder: (context, i) => TarjetaPosicion(
                            fila: tabla[i],
                            esMiFicha: tabla[i].fichaId == widget.fichaId,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
