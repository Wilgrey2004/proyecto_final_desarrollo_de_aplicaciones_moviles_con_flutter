import 'package:equatable/equatable.dart';

class NewsModel extends Equatable {
  final String id;
  final String titulo;
  final String contenido;
  final String resumen;
  final String? imagen;
  final String autor;
  final DateTime fechaPublicacion;
  final List<String> tags;
  final bool destacada;
  final int vistas;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NewsModel({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.resumen,
    this.imagen,
    required this.autor,
    required this.fechaPublicacion,
    this.tags = const [],
    this.destacada = false,
    this.vistas = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      resumen: json['resumen'] ?? '',
      imagen: json['imagen'],
      autor: json['autor'] ?? '',
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.tryParse(json['fecha_publicacion']) ?? DateTime.now()
          : DateTime.now(),
      tags: json['tags'] != null
          ? List<String>.from(
              json['tags'].toString().split(',').map((e) => e.trim()),
            )
          : [],
      destacada: json['destacada'] == 1 || json['destacada'] == true,
      vistas: json['vistas'] ?? 0,
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
      'contenido': contenido,
      'resumen': resumen,
      'imagen': imagen,
      'autor': autor,
      'fecha_publicacion': fechaPublicacion.toIso8601String(),
      'tags': tags.join(','),
      'destacada': destacada,
      'vistas': vistas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
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

  NewsModel copyWith({
    String? id,
    String? titulo,
    String? contenido,
    String? resumen,
    String? imagen,
    String? autor,
    DateTime? fechaPublicacion,
    List<String>? tags,
    bool? destacada,
    int? vistas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      resumen: resumen ?? this.resumen,
      imagen: imagen ?? this.imagen,
      autor: autor ?? this.autor,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      tags: tags ?? this.tags,
      destacada: destacada ?? this.destacada,
      vistas: vistas ?? this.vistas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    contenido,
    resumen,
    imagen,
    autor,
    fechaPublicacion,
    tags,
    destacada,
    vistas,
    createdAt,
    updatedAt,
  ];
}
