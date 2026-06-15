import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incidencia.dart';

class ApiService {
  // IMPORTANTE: cambiar esta URL por la que entrega ngrok cuando se exponga la API.
  // Ejemplo: 'https://abc123.ngrok-free.app'
  // Si se prueba con emulador Android y la API corre en el PC, usar: 'http://10.0.2.2:5000'
  static const String baseUrl = 'https://family-extended-tutu.ngrok-free.dev';

  // ---------- LISTAR ----------
  Future<List<Incidencia>> listarIncidencias({String? filtroEstado}) async {
    final url = filtroEstado != null
        ? '$baseUrl/api/incidencias?estado=$filtroEstado'
        : '$baseUrl/api/incidencias';

    final response = await http.get(
      Uri.parse(url),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Incidencia.fromJson(j)).toList();
    } else {
      throw Exception('Error al cargar incidencias (HTTP ${response.statusCode})');
    }
  }

  // ---------- OBTENER UNA ----------
  Future<Incidencia> obtenerIncidencia(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/incidencias/$id'),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    if (response.statusCode == 200) {
      return Incidencia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Incidencia no encontrada');
    }
  }

  // ---------- CREAR ----------
  Future<Incidencia> crearIncidencia(Incidencia incidencia) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/incidencias'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(incidencia.toJson()),
    );

    if (response.statusCode == 201) {
      return Incidencia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear la incidencia');
    }
  }

  // ---------- ACTUALIZAR ----------
  Future<Incidencia> actualizarIncidencia(int id, Incidencia incidencia) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/incidencias/$id'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(incidencia.toJson()),
    );

    if (response.statusCode == 200) {
      return Incidencia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la incidencia');
    }
  }

  // ---------- ELIMINAR ----------
  Future<void> eliminarIncidencia(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/incidencias/$id'),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la incidencia');
    }
  }
}
