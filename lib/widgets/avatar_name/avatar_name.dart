import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AvatarName extends StatelessWidget {
  final String nombre, foto, matricula, telefono;

  const AvatarName({
    super.key,
    required this.nombre,
    required this.foto,
    required this.matricula,
    required this.telefono,
  });

  void _abrirTelegram(String numero) async {
    final url = Uri.parse("https://t.me/$numero");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _realizarLlamada(String numero) async {
    final url = Uri.parse("tel:$numero");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(foto),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 5),
                    Text(
                      "Matrícula: $matricula",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _abrirTelegram(telefono),
                          icon: const Icon(Icons.send),
                          label: const Text("Telegram"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _realizarLlamada(telefono),
                          icon: const Icon(Icons.phone),
                          label: const Text("Llamar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
