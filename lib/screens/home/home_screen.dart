import 'package:flutter/material.dart';
import 'package:proyecto_final/widgets/slider_images/slider_images_w.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inicio")),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Debemos de cuidar nuestro medio ambiente",
                    style: TextStyle(fontSize: 25, color: Colors.lightGreen),
                  ),
                ),
              ),
              CarrucelImages(),
            ],
          ),
        ),
      ),
    );
  }
}
