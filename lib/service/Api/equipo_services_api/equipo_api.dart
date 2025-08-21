import "package:http/http.dart" as http;
import 'package:proyecto_final/models/equipo_model/equipo_model.dart';

class EquipoApi {
  Future<List<EquipoModel>> fetchEquipo() async {
    final url = Uri.parse('https://adamix.net/medioambiente/equipo');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      // ignore: avoid_print
      print("error al buscar informacion del equipo ${res.statusCode}");
    }
    return EquipoModel.listFromJson(res.body);
  }
}
