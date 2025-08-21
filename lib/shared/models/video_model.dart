import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String urlVideo;
  final String? thumbnail;
  final String categoria;
  final int duracion; // in seconds
  final String? autor;
  final List<String> tags;
  final int vistas;
  final bool destacado;
  final DateTime fechaPublicacion;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VideoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.urlVideo,
    this.thumbnail,
    required this.categoria,
    this.duracion = 0,
    this.autor,
    this.tags = const [],
    this.vistas = 0,
    this.destacado = false,
    required this.fechaPublicacion,
    required this.createdAt,
    this.updatedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      urlVideo: json['url_video'] ?? '',
      thumbnail: json['thumbnail'],
      categoria: json['categoria'] ?? '',
      duracion: json['duracion'] ?? 0,
      autor: json['autor'],
      tags: json['tags'] != null
          ? List<String>.from(
              json['tags'].toString().split(',').map((e) => e.trim()),
            )
          : [],
      vistas: json['vistas'] ?? 0,
      destacado: json['destacado'] == 1 || json['destacado'] == true,
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.tryParse(json['fecha_publicacion']) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'url_video': urlVideo,
      'thumbnail': thumbnail,
      'categoria': categoria,
      'duracion': duracion,
      'autor': autor,
      'tags': tags.join(','),
      'vistas': vistas,
      'destacado': destacado,
      'fecha_publicacion': fechaPublicacion.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedDuration {
    if (duracion <= 0) return '0:00';

    final hours = duracion ~/ 3600;
    final minutes = (duracion % 3600) ~/ 60;
    final seconds = duracion % 60;

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(fechaPublicacion);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'hace ${years} año${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace ${months} mes${months > 1 ? 'es' : ''}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  String get formattedViews {
    if (vistas >= 1000000) {
      return '${(vistas / 1000000).toStringAsFixed(1)}M visualizaciones';
    } else if (vistas >= 1000) {
      return '${(vistas / 1000).toStringAsFixed(1)}K visualizaciones';
    } else {
      return '$vistas visualizaciones';
    }
  }

  VideoModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? urlVideo,
    String? thumbnail,
    String? categoria,
    int? duracion,
    String? autor,
    List<String>? tags,
    int? vistas,
    bool? destacado,
    DateTime? fechaPublicacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      urlVideo: urlVideo ?? this.urlVideo,
      thumbnail: thumbnail ?? this.thumbnail,
      categoria: categoria ?? this.categoria,
      duracion: duracion ?? this.duracion,
      autor: autor ?? this.autor,
      tags: tags ?? this.tags,
      vistas: vistas ?? this.vistas,
      destacado: destacado ?? this.destacado,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    urlVideo,
    thumbnail,
    categoria,
    duracion,
    autor,
    tags,
    vistas,
    destacado,
    fechaPublicacion,
    createdAt,
    updatedAt,
  ];
}
