import 'package:flutter/material.dart';
import 'package:proyecto_final/screens/home/home_screen.dart';
import 'package:proyecto_final/screens/protected_areas_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MainScreen(),
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
  //deben de agregar sus widget aqui y luego agregarles un icono en el mismo orden.
  final List<Widget> _pages = [
    HomeScreen(),
    const Center(child: Text('Lista')),
    const Center(child: Text('Acerca')),
    const ProtectedAreasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Cambia el contenido según el índice
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // <- importante
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Lista"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Acerca"),
          BottomNavigationBarItem(icon: Icon(Icons.nature), label: "Áreas"),
        ],
      ),
    );
  }
}
