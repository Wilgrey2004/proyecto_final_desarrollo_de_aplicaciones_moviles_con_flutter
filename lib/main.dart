import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto_final/screens/about_us/about_us_screen.dart';
import 'package:proyecto_final/screens/home/home_screen.dart';
import 'package:proyecto_final/screens/protected_areas_screens/protected_areas_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:proyecto_final/screens/medidas_ambientales_screen/medidas_ambientales_screen.dart';
import 'package:proyecto_final/screens/normativas_screen.dart'; // 👈 importa la screen de normativas
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 👇 Agrega NormativasScreen a la lista de páginas
  final List<Widget> _pages = [
    const HomeScreen(),
    const AboutUsScreen(),
    const MedidasAmbientalesScreen(),
    const ProtectedAreasScreen(),
    const NormativasScreen(), // <- nuevo
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
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel), // 👈 icono para normativas
            label: "Normativas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Areas protegidas",
          ),
        ],
      ),
    );
  }
}
