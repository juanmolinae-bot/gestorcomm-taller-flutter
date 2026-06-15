import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incidencia.dart';
import '../services/api_service.dart';
import 'lista_screen.dart';
import 'detalle_screen.dart';
import 'formulario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  late Future<List<Incidencia>> _futureIncidencias;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureIncidencias = _api.listarIncidencias();
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
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text('GestorComm'),
            const SizedBox(width: 20),
            _navLink('Inicio', true),
            const SizedBox(width: 4),
            _navLink('Incidencias', false, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaScreen()))
                  .then((_) => _cargar());
            }),
            const SizedBox(width: 4),
            _navLink('+ Nueva', false, onTap: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const FormularioScreen()),
              );
              if (created == true) _cargar();
            }),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargar(),
        child: FutureBuilder<List<Incidencia>>(
          future: _futureIncidencias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _errorView(snapshot.error);
            }
            final lista = snapshot.data ?? [];
            final abiertas = lista.where((i) => i.estado == 'abierta').length;
            final enRevision = lista.where((i) => i.estado == 'en_revision').length;
            final cerradas = lista.where((i) => i.estado == 'cerrada' || i.estado == 'resuelta').length;
            final recientes = lista.take(5).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Resumen',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 12),

                _tarjetaResumen(
                  label: 'Abiertas',
                  valor: abiertas,
                  color: const Color(0xFFD32F2F),
                ),
                const SizedBox(height: 10),
                _tarjetaResumen(
                  label: 'En revisión',
                  valor: enRevision,
                  color: const Color(0xFFF57C00),
                ),
                const SizedBox(height: 10),
                _tarjetaResumen(
                  label: 'Cerradas',
                  valor: cerradas,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(height: 24),
                const Text(
                  'Incidencias recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 8),

                ...recientes.map((inc) => _filaIncidencia(inc)),

                if (recientes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No hay incidencias', style: TextStyle(color: Colors.grey))),
                  ),
              ],
            );
          },
        ),
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

  Widget _navLink(String text, bool active, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _tarjetaResumen({
    required String label,
    required int valor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaIncidencia(Incidencia inc) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
            '${inc.zona} · ${_formatFecha(inc.fechaCreacion)}',
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
            MaterialPageRoute(builder: (_) => DetalleScreen(incidenciaId: inc.id!)),
          );
          _cargar();
        },
      ),
    );
  }

  Widget _errorView(Object? error) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text('Error al conectar con la API',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}
