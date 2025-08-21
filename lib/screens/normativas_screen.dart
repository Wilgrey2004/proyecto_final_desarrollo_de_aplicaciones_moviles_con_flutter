import 'package:flutter/material.dart';
import '../models/normativa_model.dart';
import '../service/normativa_service.dart';

class NormativasScreen extends StatefulWidget {
  const NormativasScreen({super.key});

  @override
  State<NormativasScreen> createState() => _NormativasScreenState();
}

class _NormativasScreenState extends State<NormativasScreen> {
  late Future<List<Normativa>> normativasFuture;
  List<Normativa> _allNormativas = [];
  List<Normativa> _filteredNormativas = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedTipo = '';

  final List<Map<String, String>> tipos = [
    {'label': 'Todos', 'value': ''},
    {'label': 'Ley', 'value': 'ley'},
    {'label': 'Reglamento', 'value': 'reglamento'},
    {'label': 'Resolución', 'value': 'resolucion'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNormativas();
  }

  void _loadNormativas() {
    normativasFuture = NormativaService().fetchNormativas(tipo: _selectedTipo);
    normativasFuture
        .then((list) {
          _allNormativas = list;
          _filteredNormativas = _allNormativas;
          setState(() {});
        })
        .catchError((error) {
          // ignore: avoid_print
          print('Error al cargar normativas: $error');
        });
  }

  void _filterNormativas(String query) {
    final filtered = _allNormativas
        .where((n) => n.titulo.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredNormativas = filtered;
    });
  }

  void _selectTipo(String tipo) {
    setState(() {
      _selectedTipo = tipo;
      _loadNormativas();
      _searchController.clear();
    });
  }

  void _showNormativaDetail(Normativa normativa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NormativaDetailScreen(normativa: normativa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Normativas Ambientales')),
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
                          : Colors.grey[300],
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
                hintText: 'Buscar normativa',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterNormativas,
            ),
          ),
          // Listado
          Expanded(
            child: _allNormativas.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredNormativas.isEmpty
                ? const Center(child: Text('No se encontraron normativas'))
                : ListView.builder(
                    itemCount: _filteredNormativas.length,
                    itemBuilder: (context, index) {
                      final n = _filteredNormativas[index];
                      return ListTile(
                        title: Text(n.titulo),
                        subtitle: Text('${n.tipo} • ${n.numero}'),
                        onTap: () => _showNormativaDetail(n),
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
class NormativaDetailScreen extends StatelessWidget {
  final Normativa normativa;
  const NormativaDetailScreen({super.key, required this.normativa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(normativa.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo: ${normativa.tipo}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Número: ${normativa.numero}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${normativa.fechaPublicacion}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(normativa.descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (normativa.urlDocumento.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  // Abrir documento en navegador
                  // usa url_launcher
                },
                child: const Text('Ver documento completo'),
              ),
          ],
        ),
      ),
    );
  }
}
