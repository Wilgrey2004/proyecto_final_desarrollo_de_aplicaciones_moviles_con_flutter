import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto_final/screens/about_us/about_us_screen.dart';
import 'package:proyecto_final/screens/equipo_screen/equipo_screen.dart';
import 'package:proyecto_final/screens/home/home_screen.dart';
import 'package:proyecto_final/screens/protected_areas_screens/protected_areas_screen.dart';
import 'package:proyecto_final/screens/medidas_ambientales_screen/medidas_ambientales_screen.dart';
import 'package:proyecto_final/screens/normativas_screen/normativas_screen.dart';
import 'package:proyecto_final/screens/videos/videos_page.dart';
import 'package:proyecto_final/widgets/Formulario_widget_api/formulario_voluntariado.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    // InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const AboutUsScreen(),
    const MedidasAmbientalesScreen(),
    const ProtectedAreasScreen(),
    const NormativasScreen(),
    const EquipoScreen(),
    const VideosPage(),
    const VoluntariadoForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_sharp),
            label: "Sobre nosotros",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Medidas"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Áreas protegidas",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: "Normativas"),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Equipo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video),
            label: "Videos",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.join_full),
            label: "Voluntariado",
          ),
        ],
      ),
    );
  }
}
