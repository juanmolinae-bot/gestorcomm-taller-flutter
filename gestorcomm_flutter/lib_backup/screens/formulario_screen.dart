import 'package:flutter/material.dart';
import '../models/incidencia.dart';
import '../services/api_service.dart';

class FormularioScreen extends StatefulWidget {
  final Incidencia? incidencia;  // si viene null, es crear; si trae datos, es editar
  const FormularioScreen({super.key, this.incidencia});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  late TextEditingController _tituloCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _zonaCtrl;
  String _prioridad = 'media';
  String _estado = 'abierta';
  bool _guardando = false;

  bool get _esEdicion => widget.incidencia != null;

  @override
  void initState() {
    super.initState();
    final inc = widget.incidencia;
    _tituloCtrl = TextEditingController(text: inc?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: inc?.descripcion ?? '');
    _zonaCtrl = TextEditingController(text: inc?.zona ?? '');
    _prioridad = inc?.prioridad ?? 'media';
    _estado = inc?.estado ?? 'abierta';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _zonaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final nueva = Incidencia(
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      zona: _zonaCtrl.text.trim(),
      prioridad: _prioridad,
      estado: _estado,
    );

    try {
      if (_esEdicion) {
        await _api.actualizarIncidencia(widget.incidencia!.id!, nueva);
      } else {
        await _api.crearIncidencia(nueva);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_esEdicion ? 'Incidencia actualizada' : 'Incidencia creada')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar incidencia' : 'Nueva incidencia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zonaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Zona *',
                  hintText: 'Ej: Inversores, BESS, SE Futuro',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _prioridad,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'baja', child: Text('Baja')),
                  DropdownMenuItem(value: 'media', child: Text('Media')),
                  DropdownMenuItem(value: 'alta', child: Text('Alta')),
                  DropdownMenuItem(value: 'critica', child: Text('Crítica')),
                ],
                onChanged: (v) => setState(() => _prioridad = v ?? 'media'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'abierta', child: Text('Abierta')),
                  DropdownMenuItem(value: 'en_revision', child: Text('En revisión')),
                  DropdownMenuItem(value: 'resuelta', child: Text('Resuelta')),
                  DropdownMenuItem(value: 'cerrada', child: Text('Cerrada')),
                ],
                onChanged: (v) => setState(() => _estado = v ?? 'abierta'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_esEdicion ? 'Guardar cambios' : 'Crear incidencia'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
