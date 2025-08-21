import 'package:flutter/material.dart';
import 'package:proyecto_final/service/Api/equipo_services_api/equipo_api.dart';
import 'package:proyecto_final/widgets/Lista_widget_api/lista_equipo.dart';
import 'package:proyecto_final/widgets/Texts/custom_text_to_titles.dart';

class EquipoScreen extends StatelessWidget {
  const EquipoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    EquipoApi equipoApi = EquipoApi();
    return Scaffold(
      appBar: AppBar(title: Text("Lista de integrantes del equipo")),
      body: Column(
        children: [
          CustomTextToTitles(title: "Listado💾"),
          SizedBox(height: 20),
          Expanded(child: EquipoList(future: equipoApi.fetchEquipo())),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
