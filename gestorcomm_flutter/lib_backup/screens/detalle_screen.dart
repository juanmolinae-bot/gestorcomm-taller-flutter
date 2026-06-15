import 'package:flutter/material.dart';
import '../models/incidencia.dart';
import '../services/api_service.dart';
import 'formulario_screen.dart';

class DetalleScreen extends StatefulWidget {
  final int incidenciaId;
  const DetalleScreen({super.key, required this.incidenciaId});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final ApiService _api = ApiService();
  late Future<Incidencia> _futureIncidencia;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureIncidencia = _api.obtenerIncidencia(widget.incidenciaId);
    });
  }

  Future<void> _confirmarEliminacion(Incidencia inc) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar incidencia?'),
        content: Text('Se eliminará "${inc.titulo}". Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _api.eliminarIncidencia(inc.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidencia eliminada')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: FutureBuilder<Incidencia>(
        future: _futureIncidencia,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final inc = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inc.titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(inc.estadoLabel),
                      backgroundColor: Colors.purple.shade50,
                    ),
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(inc.prioridadLabel),
                      backgroundColor: Colors.orange.shade50,
                    ),
                  ],
                ),
                const Divider(height: 32),
                _infoRow(Icons.place, 'Zona', inc.zona),
                _infoRow(Icons.access_time, 'Fecha', inc.fechaCreacion ?? 'Sin fecha'),
                const SizedBox(height: 16),
                const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(inc.descripcion.isEmpty ? '(Sin descripción)' : inc.descripcion),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => FormularioScreen(incidencia: inc)),
                          );
                          if (updated == true) _cargar();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                        onPressed: () => _confirmarEliminacion(inc),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
