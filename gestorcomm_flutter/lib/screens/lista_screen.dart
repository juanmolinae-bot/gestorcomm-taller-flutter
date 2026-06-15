import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureIncidencias = _api.listarIncidencias(filtroEstado: _filtroEstado);
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
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const Divider(height: 1),
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text('Error al conectar con la API'),
                          const SizedBox(height: 8),
                          Text('${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _cargar,
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
                    child: Text('No hay incidencias',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _cargar(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final inc = lista[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            inc.titulo,
                            style: const TextStyle(
                              color: Color(0xFF1E5FA8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${inc.zona} · ${_formatFecha(inc.fechaCreacion)} · Prioridad ${inc.prioridadLabel}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: _colorEstado(inc.estado), width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inc.estadoLabel,
                              style: TextStyle(
                                color: _colorEstado(inc.estado),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleScreen(incidenciaId: inc.id!),
                              ),
                            );
                            _cargar();
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
          if (created == true) _cargar();
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
      selectedColor: const Color(0xFF1E5FA8).withOpacity(0.15),
      labelStyle: TextStyle(
        color: activo ? const Color(0xFF1E5FA8) : Colors.grey.shade700,
        fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: activo ? const Color(0xFF1E5FA8) : Colors.grey.shade300,
      ),
      onSelected: (_) {
        setState(() {
          _filtroEstado = valor;
        });
        _cargar();
      },
    );
  }
}
