import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/normativa_model.dart';

class NormativaService {
  final String baseUrl =
      'https://adamix.net/medioambiente'; // reemplaza con tu URL

  Future<List<Normativa>> fetchNormativas({
    String tipo = '',
    String busqueda = '',
  }) async {
    final uri = Uri.parse(
      '$baseUrl/normativas',
    ).replace(queryParameters: {'tipo': tipo, 'busqueda': busqueda});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((e) => Normativa.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar normativas');
    }
  }
}
