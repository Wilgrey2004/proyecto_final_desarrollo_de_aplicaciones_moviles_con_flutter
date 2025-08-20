import 'package:flutter/material.dart';
import 'package:proyecto_final/models/protected_area_model.dart';
import "../service/protected_area_service.dart";
import "../screens/protected_areas_map.dart";

class ProtectedAreasScreen extends StatefulWidget {
  const ProtectedAreasScreen({super.key});

  @override
  State<ProtectedAreasScreen> createState() => _ProtectedAreasScreenState();
}

class _ProtectedAreasScreenState extends State<ProtectedAreasScreen> {
  late Future<List<ProtectedArea>> areasFuture;
  List<ProtectedArea> _allAreas = [];
  List<ProtectedArea> _filteredAreas = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedTipo = '';
  bool showMap = false; // Alterna entre lista y mapa

  // Imagen por defecto
  final String defaultImage = 'assets/default_area.jpg';

  // Mapa de imágenes
  final Map<String, String> localImages = {
    'Boca Chica': 'assets/boca_chica.jpg',
    'Dunas de Bani': 'assets/dunas_bani.jpg',
    'Reserva Científica Ébano Verde': 'assets/ebano_verde.jpg',
    'Laguna Cabral o Rincón': 'assets/laguna_cabral.jpg',
    'Loma Quita Espuela': 'assets/loma_quita_espuela.jpg',
    'Parque Nacional Los Haitises': 'assets/PN_haitises.jpg',
    'Parque Nacional Jaragua': 'assets/PN_jaragua.png',
    'Reserva Científica Valle Nuevo': 'assets/reserva_valleNuevo.jpg',
    'Santuario de Mamíferos Marinos Bancos de La Plata y Navidad':
        'assets/santuario_mamiferos_blancos.jpg',
    'Sierra de Bahoruco': 'assets/sierra_bahoruco.jpg',
  };

  final List<Map<String, String>> tipos = [
    {'label': 'Todos', 'value': ''},
    {'label': 'Parque Nacional', 'value': 'parque_nacional'},
    {'label': 'Reserva Científica', 'value': 'reserva_cientifica'},
    {'label': 'Monumento Natural', 'value': 'monumento_natural'},
    {'label': 'Refugio de Vida Silvestre', 'value': 'refugio_vida_silvestre'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  void _loadAreas() {
    areasFuture = ProtectedAreaService().fetchAreas(tipo: _selectedTipo);
    areasFuture
        .then((list) {
          _allAreas = list.map((area) {
            String imgPath = defaultImage;
            localImages.forEach((key, value) {
              if (area.nombre.contains(key)) {
                imgPath = value;
              }
            });

            return ProtectedArea(
              id: area.id,
              nombre: area.nombre,
              tipo: area.tipo,
              ubicacion: area.ubicacion,
              superficie: area.superficie,
              descripcion: area.descripcion,
              latitud: area.latitud,
              longitud: area.longitud,
              fechaCreacion: area.fechaCreacion,
              imagen: imgPath,
            );
          }).toList();

          _filteredAreas = _allAreas;
          setState(() {});
        })
        .catchError((error) {
          print('Error loading areas: $error');
        });
  }

  void _filterAreas(String query) {
    final filtered = _allAreas
        .where(
          (area) =>
              area.nombre.toLowerCase().contains(query.toLowerCase()) ||
              area.ubicacion.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    setState(() {
      _filteredAreas = filtered;
    });
  }

  void _selectTipo(String tipo) {
    setState(() {
      _selectedTipo = tipo;
      _loadAreas();
      _searchController.clear();
    });
  }

  void _showAreaDetail(ProtectedArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AreaDetailScreen(area: area, defaultImage: defaultImage),
      ),
    );
  }

  Widget _buildImage(String path, {double width = 60, double height = 60}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          defaultImage,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Áreas Protegidas"),
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                showMap = !showMap;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por tipo
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tipos.length,
              itemBuilder: (context, index) {
                final tipo = tipos[index];
                final isSelected = _selectedTipo == tipo['value'];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.green
                          : const Color.fromARGB(255, 231, 231, 231),
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    onPressed: () => _selectTipo(tipo['value']!),
                    child: Text(tipo['label']!),
                  ),
                );
              },
            ),
          ),
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Buscar área protegida",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterAreas,
            ),
          ),
          // Lista o Mapa
          Expanded(
            child: showMap
                ? ProtectedAreasMapScreen(areas: _filteredAreas)
                : _allAreas.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredAreas.isEmpty
                ? const Center(child: Text('No se encontraron áreas'))
                : ListView.builder(
                    itemCount: _filteredAreas.length,
                    itemBuilder: (context, index) {
                      final area = _filteredAreas[index];
                      return ListTile(
                        leading: _buildImage(area.imagen),
                        title: Text(area.nombre),
                        subtitle: Text('${area.tipo} • ${area.ubicacion}'),
                        onTap: () => _showAreaDetail(area),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de detalle
class AreaDetailScreen extends StatelessWidget {
  final ProtectedArea area;
  final String defaultImage;
  const AreaDetailScreen({
    super.key,
    required this.area,
    required this.defaultImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(area.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailImage(area.imagen),
            const SizedBox(height: 16),
            Text('Tipo: ${area.tipo}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Ubicación: ${area.ubicacion}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Superficie: ${area.superficie}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(area.descripcion, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailImage(String path) {
    return Image.asset(
      path,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          defaultImage,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
