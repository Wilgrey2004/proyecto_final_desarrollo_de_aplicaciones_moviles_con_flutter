import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_final/models/voluntariado_model/voluntariado_model.dart';

Future<void> enviarVoluntariado(VoluntariadoModel voluntario) async {
  final url = Uri.parse("http://tu-api.com/api/voluntariados");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(voluntario.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    // ignore: avoid_print
    print("✅ Enviado con éxito");
  } else {
    // ignore: avoid_print
    print("❌ Error: ${response.statusCode}");
    // ignore: avoid_print
    print(response.body);
  }
}
