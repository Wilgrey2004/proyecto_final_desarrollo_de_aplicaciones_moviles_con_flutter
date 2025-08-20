import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proyecto_final/models/Medidas_model/medidas_model.dart';
import 'package:proyecto_final/widgets/Texts/custom_text_to_paragraf.dart';
import 'package:proyecto_final/widgets/Texts/custom_text_to_titles.dart';

Future<List<Medidas>> fetchMedidas() async {
  final res = await http.get(
    Uri.parse('https://adamix.net/medioambiente/medidas'),
  );
  if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
  final List parsed = json.decode(res.body) as List;
  return parsed.map((e) => Medidas.fromJson(e)).toList();
}

class ListaMedidas extends StatefulWidget {
  const ListaMedidas({super.key});

  @override
  State<ListaMedidas> createState() => _ListaMedidasState();
}

class _ListaMedidasState extends State<ListaMedidas> {
  late Future<List<Medidas>> futureMedidas;

  @override
  void initState() {
    super.initState();

    futureMedidas = fetchMedidas();
  }

  Future<void> _refresh() async {
    setState(() => futureMedidas = fetchMedidas());
    await futureMedidas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medidas')),
      body: FutureBuilder<List<Medidas>>(
        future: futureMedidas,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final m = items[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Text(m.icono),
                      title: Text(m.titulo),
                      subtitle: Text("Categoria ${m.categoria}"),
                      onTap: () {
                        _showDetalle(context, m);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

void _showDetalle(BuildContext ctx, Medidas m) {
  showModalBottomSheet(
    context: ctx,
    builder: (_) => Container(
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.all(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextToTitles(title: "${m.titulo} ${m.icono}"),
            SizedBox(height: 20),
            CustomTextToParagraf(Texto: m.descripcion),
            CustomTextToParagraf(Texto: m.fechaCreacion),
          ],
        ),
      ),
    ),
  );
}
