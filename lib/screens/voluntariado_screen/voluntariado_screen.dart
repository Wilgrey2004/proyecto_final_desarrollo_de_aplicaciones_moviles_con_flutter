import 'package:flutter/material.dart';
import 'package:proyecto_final/widgets/Formulario_widget_api/formulario_voluntariado.dart';
import 'package:proyecto_final/widgets/Texts/custom_text_to_titles.dart';

class VoluntariadoScreen extends StatelessWidget {
  const VoluntariadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("voluntariado")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextToTitles(title: "Rellena esto para el voluntariado"),
              SizedBox(height: 20),
              Expanded(child: VoluntariadoForm()),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
