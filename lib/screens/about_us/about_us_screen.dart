import 'package:flutter/material.dart';
import 'package:proyecto_final/widgets/Texts/custom_text_to_paragraf.dart';
import 'package:proyecto_final/widgets/Texts/custom_text_to_titles.dart';
import 'package:proyecto_final/widgets/Video_Player/video_player_widget.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(title: Text("Acerca de nosotros")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomTextToTitles(title: "Mision🎯"),
              CustomTextToParagraf(
                Texto:
                    "Garantizar la conservación del medio ambiente y los recursos naturales de la República Dominicana, mediante la rectoría y regulación de la política medioambiental.",
              ),
              SizedBox(height: 20),
              CustomTextToTitles(title: "Vision👁️"),
              CustomTextToParagraf(
                Texto:
                    "Institución reconocida por su eficacia con la conservación del medio ambiente y los recursos naturales enfocado en el desarrollo sostenible del país, con una gestión funcionalmente integrada, eficiente y de calidad.",
              ),
              SizedBox(height: 20),
              CustomTextToTitles(title: "Historia🖼️"),
              CustomTextToParagraf(
                Texto:
                    "En lo referente a protección del medio ambiente, en 1844 se dicta el decreto n.º 2295 sobre la conservación de bosques y selvas pertenecientes al territorio nacional.[4]​ La siguiente legislación medioambiental no llegará hasta 1928, cuando se firma la Ley n.º 944 sobre la protección de montes y aguas y sobre la creación de reservas forestales. Ese mismo año se comienza a delimitar el entorno del Yaque del Norte como área protegida. En 1931, se promulga la Ley n.º 85 sobre biodiversidad, vida silvestre y caza. En 1965 se crea el Instituto Nacional de Recursos Hidráulicos (INDRHI). En 1967 se establece el entorno del mar territorial de la República Dominicana.",
              ),
              SizedBox(height: 20),
              CustomTextToTitles(title: "Video🎞️"),
              SizedBox(height: 250, child: YouTubePlayerWidget()),
              SizedBox(height: 20),
              CustomTextToTitles(title: "Texto explicativo"),
              CustomTextToParagraf(
                Texto:
                    "El Ministerio de Medio Ambiente y Recursos Naturales (MMARN) es el organismo estatal responsable de proteger, conservar y sancionar las acciones que atenten contra los recursos naturales de la República Dominicana",
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
