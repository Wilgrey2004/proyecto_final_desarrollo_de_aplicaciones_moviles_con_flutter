import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_final/models/protected_area_model.dart';
import 'protected_areas_screen.dart';

class ProtectedAreasMapScreen extends StatelessWidget {
  final List<ProtectedArea> areas;
  const ProtectedAreasMapScreen({super.key, required this.areas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Áreas Protegidas")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(18.7357, -70.1627), // centro de RD
          initialZoom: 7.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: areas.map((area) {
              return Marker(
                point: LatLng(area.latitud, area.longitud),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AreaDetailScreen(area: area, defaultImage: ''),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
