import 'package:flutter/material.dart';
import 'package:proyecto_final/widgets/avatar_name/avatar_name.dart';

class AcercaDeScreen extends StatelessWidget {
  const AcercaDeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Acerca de nuestro equipo de desarrollo")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AvatarName(
                nombre: "Wilgrey Ravelo Cruz",
                foto: "https://i.postimg.cc/66dF3nSm/image.png",
                matricula: "2023-0611",
                telefono: "8494061420",
              ),

              AvatarName(
                nombre: "Erick Daniel Cuesto Méndez",
                foto: "https://i.postimg.cc/KjqPz9yT/Mi-Foto-1.jpg",
                matricula: "2023-0650",
                telefono: "8098681783",
              ),

              AvatarName(
                nombre: "Julio Oniel Batista",
                foto:
                    "https://i.postimg.cc/mrH8nGW5/Imagen-de-Whats-App-2025-08-21-a-las-12-31-55-babe453f.jpg",
                matricula: "2022-2145",
                telefono: "8294107270",
              ),

              AvatarName(
                nombre: "Norkys G. Sanchez",
                foto:
                    "https://i.postimg.cc/3wsbrxZh/Imagen-de-Whats-App-2025-08-21-a-las-10-47-22-651dda99.jpg",
                matricula: "2021-0322",
                telefono: "8099749584",
              ),

              AvatarName(
                nombre: "Jose Angel L. Castillo",
                foto:
                    "https://i.postimg.cc/L5TyVBF4/Imagen-de-Whats-App-2025-08-21-a-las-10-46-20-d5211460.jpg",
                matricula: "2021-0012",
                telefono: "8094964913",
              ),

              AvatarName(
                nombre: "Jean Carlos Castillo",
                foto:
                    "https://i.postimg.cc/jS9MvSmf/Imagen-de-Whats-App-2025-08-21-a-las-10-46-00-4a741a10.jpg",
                matricula: "2023-0665",
                telefono: "8297490064",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
