import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/protected_area_model.dart';

class ProtectedAreaService {
  /// Base URL de la API
  final String baseUrl = "https://adamix.net/medioambiente/";

  /// Base URL para las imágenes
  final String baseImageUrl = "https://adamix.net/medioambiente";

  /// Obtiene la lista de áreas protegidas con filtros opcionales
  Future<List<ProtectedArea>> fetchAreas({
    String tipo = '',
    String busqueda = '',
  }) async {
    try {
      final queryParameters = {
        if (tipo.isNotEmpty) 'tipo': tipo,
        if (busqueda.isNotEmpty) 'busqueda': busqueda,
      };

      final uri = Uri.parse(
        '${baseUrl}areas_protegidas',
      ).replace(queryParameters: queryParameters);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body);
        return jsonList.map((json) => ProtectedArea.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al cargar áreas protegidas: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  /// Devuelve la URL completa de la imagen de un área protegida
  String getImageUrl(String relativePath) {
    if (relativePath.isEmpty) return '';
    // Asegura que tenga "/" entre base y path
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$baseImageUrl$path';
  }
}
