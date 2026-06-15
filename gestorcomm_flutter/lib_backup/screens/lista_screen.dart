import 'package:flutter/material.dart';
import '../models/incidencia.dart';
import '../services/api_service.dart';
import 'formulario_screen.dart';
import 'detalle_screen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key});

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final ApiService _api = ApiService();
  late Future<List<Incidencia>> _futureIncidencias;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _cargarIncidencias();
  }

  void _cargarIncidencias() {
    setState(() {
      _futureIncidencias = _api.listarIncidencias(filtroEstado: _filtroEstado);
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'abierta': return Colors.red.shade400;
      case 'en_revision': return Colors.amber.shade600;
      case 'resuelta': return Colors.green.shade500;
      case 'cerrada': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }

  IconData _iconoPrioridad(String prioridad) {
    switch (prioridad) {
      case 'critica': return Icons.warning_amber_rounded;
      case 'alta': return Icons.priority_high;
      case 'media': return Icons.adjust;
      default: return Icons.low_priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GestorComm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarIncidencias,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chipFiltro('Todas', null),
                  const SizedBox(width: 6),
                  _chipFiltro('Abiertas', 'abierta'),
                  const SizedBox(width: 6),
                  _chipFiltro('En revisión', 'en_revision'),
                  const SizedBox(width: 6),
                  _chipFiltro('Resueltas', 'resuelta'),
                  const SizedBox(width: 6),
                  _chipFiltro('Cerradas', 'cerrada'),
                ],
              ),
            ),
          ),

          // lista
          Expanded(
            child: FutureBuilder<List<Incidencia>>(
              future: _futureIncidencias,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error al conectar con la API',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _cargarIncidencias,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final lista = snapshot.data ?? [];
                if (lista.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay incidencias registradas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _cargarIncidencias(),
                  child: ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final inc = lista[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(_iconoPrioridad(inc.prioridad), color: _colorEstado(inc.estado)),
                          title: Text(inc.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${inc.zona} · ${inc.prioridadLabel}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _colorEstado(inc.estado),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              inc.estadoLabel,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleScreen(incidenciaId: inc.id!),
                              ),
                            );
                            _cargarIncidencias();
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const FormularioScreen()),
          );
          if (created == true) _cargarIncidencias();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _chipFiltro(String label, String? valor) {
    final activo = _filtroEstado == valor;
    return ChoiceChip(
      label: Text(label),
      selected: activo,
      onSelected: (_) {
        setState(() {
          _filtroEstado = valor;
        });
        _cargarIncidencias();
      },
    );
  }
}
