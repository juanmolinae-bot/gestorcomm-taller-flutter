class Incidencia {
  final int? id;
  final String titulo;
  final String descripcion;
  final String zona;
  final String prioridad;
  final String estado;
  final String? fechaCreacion;

  Incidencia({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.zona,
    required this.prioridad,
    required this.estado,
    this.fechaCreacion,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      zona: json['zona'] ?? '',
      prioridad: json['prioridad'] ?? 'media',
      estado: json['estado'] ?? 'abierta',
      fechaCreacion: json['fecha_creacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'zona': zona,
      'prioridad': prioridad,
      'estado': estado,
    };
  }

  // helpers para display
  String get estadoLabel {
    switch (estado) {
      case 'abierta': return 'Abierta';
      case 'en_revision': return 'En revisión';
      case 'resuelta': return 'Resuelta';
      case 'cerrada': return 'Cerrada';
      default: return estado;
    }
  }

  String get prioridadLabel {
    return prioridad[0].toUpperCase() + prioridad.substring(1);
  }
}
