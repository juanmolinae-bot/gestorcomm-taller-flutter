import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'abierta': return const Color(0xFFD32F2F);
      case 'en_revision': return const Color(0xFFF57C00);
      case 'resuelta': return const Color(0xFF388E3C);
      case 'cerrada': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }

  String _formatFecha(String? iso) {
    if (iso == null) return 'Sin fecha';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
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
      appBar: AppBar(title: const Text('Detalle de incidencia')),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inc.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E5FA8),
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: _colorEstado(inc.estado)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inc.estadoLabel,
                              style: TextStyle(
                                color: _colorEstado(inc.estado),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Prioridad ${inc.prioridadLabel}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFFE65100)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _infoRow(Icons.place_outlined, 'Zona', inc.zona),
                      _infoRow(Icons.access_time, 'Fecha', _formatFecha(inc.fechaCreacion)),
                      const SizedBox(height: 12),
                      const Text('Descripción',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                      const SizedBox(height: 6),
                      Text(inc.descripcion.isEmpty ? '(Sin descripción)' : inc.descripcion,
                          style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: const Color(0xFF1E5FA8),
                          side: const BorderSide(color: Color(0xFF1E5FA8)),
                        ),
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
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.red),
                        ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
