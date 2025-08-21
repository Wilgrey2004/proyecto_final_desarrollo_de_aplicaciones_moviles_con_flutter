import 'package:flutter/material.dart';
import 'package:proyecto_final/models/equipo_model/equipo_model.dart';

class EquipoList extends StatelessWidget {
  final Future<List<EquipoModel>> future;
  const EquipoList({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EquipoModel>>(
      future: future,
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError) return Center(child: Text('Error: ${s.error}'));
        final items = s.data ?? [];
        if (items.isEmpty) return const Center(child: Text('Sin datos'));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (context, i) {
            final e = items[i];
            return Card(
              elevation: 4,
              child: ListTile(
                leading: (e.foto != null)
                    ? CircleAvatar(backgroundImage: NetworkImage(e.foto!))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(e.nombre ?? '—'),
                subtitle: Text('${e.cargo ?? ''}\n${e.departamento ?? ''}'),
                isThreeLine: true,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.nombre ?? '—',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(e.biografia ?? 'Sin biografía'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
