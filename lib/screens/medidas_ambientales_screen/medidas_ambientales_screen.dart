import 'package:flutter/material.dart';
import 'package:proyecto_final/widgets/Lista_widget_api/lista_medidas.dart';

class MedidasAmbientalesScreen extends StatelessWidget {
  const MedidasAmbientalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(title: Text("Medidas Ambientales.")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListaMedidas(),
        ),
      ),
    );
  }
}
