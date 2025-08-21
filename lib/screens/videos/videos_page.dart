import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// =======================================================
/// MODELO: estructura de un Video
/// =======================================================
class VideoEdu {
  final String id;
  final String titulo;
  final String descripcion;
  final String url;        // Link del video (YouTube o .mp4)
  final String miniatura;  // Imagen del video

  VideoEdu({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.miniatura,
  });

  // Convertir JSON que viene de la API a un objeto VideoEdu
  factory VideoEdu.fromJson(Map<String, dynamic> j) {
    return VideoEdu(
      id: (j['id'] ?? j['video_id'] ?? j['codigo'] ?? '').toString(),
      titulo: (j['titulo'] ?? j['title'] ?? 'Video').toString(),
      descripcion: (j['descripcion'] ?? j['description'] ?? '').toString(),
      url: (j['url'] ?? j['link'] ?? j['video'] ?? '').toString(),
      miniatura: (j['miniatura'] ?? j['thumbnail'] ?? j['imagen'] ?? '').toString(),
    );
  }
}

/// =======================================================
/// SERVICIO: se conecta a la API de adamix para traer videos
/// =======================================================
class MedioAmbienteApi {
  static const String baseUrl = 'https://adamix.net/medioambiente';
  static const String videosPath = '/videos'; // endpoint de los videos

  static Future<List<VideoEdu>> fetchVideos() async {
    // armar la URL completa
    final uri = Uri.parse('$baseUrl$videosPath');

    // hacer la petición HTTP
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar videos');
    }

    // convertir respuesta a JSON
    final body = json.decode(res.body);

    // la API puede devolver {datos:[...]} o directamente una lista
    final lista = (body is Map && body['datos'] is List)
        ? (body['datos'] as List)
        : (body is List ? body : <dynamic>[]);

    // mapear cada item a un objeto VideoEdu
    return lista
        .whereType<Map<String, dynamic>>()
        .map<VideoEdu>((e) => VideoEdu.fromJson(e))
        .toList();
  }
}

/// =======================================================
/// PANTALLA PRINCIPAL: lista (en cuadrícula) de videos
/// =======================================================
class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  late Future<List<VideoEdu>> _future; // futuro que carga los videos

  @override
  void initState() {
    super.initState();
    // al iniciar, llamamos la función que trae los videos
    _future = MedioAmbienteApi.fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos Educativos')),
      body: FutureBuilder<List<VideoEdu>>(
        future: _future,
        builder: (context, snap) {
          // mientras carga, muestra circulito
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // si da error
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Ocurrió un error al cargar: ${snap.error}'),
              ),
            );
          }
          // si no hay datos
          final data = snap.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No hay videos disponibles.'));
          }

          // mostrar cuadrícula con tarjetas
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columnas
              childAspectRatio: 16 / 11,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final v = data[i];
              return InkWell(
                onTap: () {
                  // al dar clic, abrir pantalla del reproductor
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VideoPlayerPage(video: v)),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // miniatura del video
                      Expanded(
                        child: v.miniatura.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: v.miniatura,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                        )
                            : const Icon(Icons.video_collection, size: 48),
                      ),
                      // título
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          v.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// =======================================================
/// PANTALLA DEL REPRODUCTOR DE VIDEO
/// =======================================================
class VideoPlayerPage extends StatefulWidget {
  final VideoEdu video;
  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  YoutubePlayerController? _yt;
  VideoPlayerController? _vp;
  ChewieController? _chewie;

  // verificar si el link es de YouTube
  bool get _isYouTube {
    final id = YoutubePlayer.convertUrlToId(widget.video.url);
    return id != null && id.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // si es de YouTube, usar YoutubePlayerController
    if (_isYouTube) {
      final id = YoutubePlayer.convertUrlToId(widget.video.url)!;
      _yt = YoutubePlayerController(
        initialVideoId: id,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    }
    // si es un archivo mp4, usar VideoPlayer + Chewie
    else if (widget.video.url.toLowerCase().endsWith('.mp4')) {
      _vp = VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
      _vp!.initialize().then((_) {
        _chewie = ChewieController(videoPlayerController: _vp!, autoPlay: true);
        setState(() {}); // refrescar la pantalla
      });
    }
  }

  @override
  void dispose() {
    // liberar memoria de los controladores
    _yt?.dispose();
    _chewie?.dispose();
    _vp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    return Scaffold(
      appBar: AppBar(title: Text(v.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // reproductor de video
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Builder(
                builder: (_) {
                  if (_isYouTube && _yt != null) {
                    return YoutubePlayer(controller: _yt!);
                  }
                  if (_chewie != null) {
                    return Chewie(controller: _chewie!);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 12),
            // descripción del video
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                v.descripcion.isNotEmpty ? v.descripcion : 'Sin descripción',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
