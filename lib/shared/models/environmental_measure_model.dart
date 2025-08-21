// lib\shared\models\environmental_measure_model.dart
import 'package:equatable/equatable.dart';

class EnvironmentalMeasureModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String? imagen;
  final String categoria;
  final String? dificultad; // Fácil, Intermedio, Avanzado
  final int? impacto; // 1-5 estrellas
  final List<String> pasos;
  final List<String> beneficios;
  final List<String> materialesNecesarios;
  final String? costo; // Gratis, Bajo, Medio, Alto
  final int? tiempoImplementacion; // en días
  final List<String> tags;
  final bool destacada;
  final int vistas;
  final int likes;
  final DateTime fechaPublicacion;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EnvironmentalMeasureModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.imagen,
    required this.categoria,
    this.dificultad,
    this.impacto,
    this.pasos = const [],
    this.beneficios = const [],
    this.materialesNecesarios = const [],
    this.costo,
    this.tiempoImplementacion,
    this.tags = const [],
    this.destacada = false,
    this.vistas = 0,
    this.likes = 0,
    required this.fechaPublicacion,
    required this.createdAt,
    this.updatedAt,
  });

  factory EnvironmentalMeasureModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentalMeasureModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'],
      categoria: json['categoria'] ?? '',
      dificultad: json['dificultad'],
      impacto: json['impacto'],
      pasos: json['pasos'] != null
          ? List<String>.from(
              json['pasos']
                  .toString()
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      beneficios: json['beneficios'] != null
          ? List<String>.from(
              json['beneficios']
                  .toString()
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      materialesNecesarios: json['materiales_necesarios'] != null
          ? List<String>.from(
              json['materiales_necesarios']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      costo: json['costo'],
      tiempoImplementacion: json['tiempo_implementacion'],
      tags: json['tags'] != null
          ? List<String>.from(
              json['tags']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      destacada: json['destacada'] == 1 || json['destacada'] == true,
      vistas: json['vistas'] ?? 0,
      likes: json['likes'] ?? 0,
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
      'imagen': imagen,
      'categoria': categoria,
      'dificultad': dificultad,
      'impacto': impacto,
      'pasos': pasos.join('\n'),
      'beneficios': beneficios.join('\n'),
      'materiales_necesarios': materialesNecesarios.join(','),
      'costo': costo,
      'tiempo_implementacion': tiempoImplementacion,
      'tags': tags.join(','),
      'destacada': destacada,
      'vistas': vistas,
      'likes': likes,
      'fecha_publicacion': fechaPublicacion.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get difficultyDisplayText {
    switch (dificultad?.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'intermedio':
        return 'Intermedio';
      case 'avanzado':
        return 'Avanzado';
      default:
        return 'No especificada';
    }
  }

  String get costDisplayText {
    switch (costo?.toLowerCase()) {
      case 'gratis':
        return 'Gratis';
      case 'bajo':
        return 'Costo Bajo';
      case 'medio':
        return 'Costo Medio';
      case 'alto':
        return 'Costo Alto';
      default:
        return 'No especificado';
    }
  }

  String get timeDisplayText {
    if (tiempoImplementacion == null) return 'No especificado';

    if (tiempoImplementacion! == 1) {
      return '1 día';
    } else if (tiempoImplementacion! < 7) {
      return '$tiempoImplementacion días';
    } else if (tiempoImplementacion! < 30) {
      final weeks = (tiempoImplementacion! / 7).round();
      return '${weeks} semana${weeks > 1 ? 's' : ''}';
    } else {
      final months = (tiempoImplementacion! / 30).round();
      return '${months} mes${months > 1 ? 'es' : ''}';
    }
  }

  String get impactDisplayText {
    if (impacto == null) return 'No evaluado';

    switch (impacto!) {
      case 1:
        return 'Impacto Bajo';
      case 2:
        return 'Impacto Medio-Bajo';
      case 3:
        return 'Impacto Medio';
      case 4:
        return 'Impacto Alto';
      case 5:
        return 'Impacto Muy Alto';
      default:
        return 'No evaluado';
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

  EnvironmentalMeasureModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? imagen,
    String? categoria,
    String? dificultad,
    int? impacto,
    List<String>? pasos,
    List<String>? beneficios,
    List<String>? materialesNecesarios,
    String? costo,
    int? tiempoImplementacion,
    List<String>? tags,
    bool? destacada,
    int? vistas,
    int? likes,
    DateTime? fechaPublicacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvironmentalMeasureModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      dificultad: dificultad ?? this.dificultad,
      impacto: impacto ?? this.impacto,
      pasos: pasos ?? this.pasos,
      beneficios: beneficios ?? this.beneficios,
      materialesNecesarios: materialesNecesarios ?? this.materialesNecesarios,
      costo: costo ?? this.costo,
      tiempoImplementacion: tiempoImplementacion ?? this.tiempoImplementacion,
      tags: tags ?? this.tags,
      destacada: destacada ?? this.destacada,
      vistas: vistas ?? this.vistas,
      likes: likes ?? this.likes,
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
    imagen,
    categoria,
    dificultad,
    impacto,
    pasos,
    beneficios,
    materialesNecesarios,
    costo,
    tiempoImplementacion,
    tags,
    destacada,
    vistas,
    likes,
    fechaPublicacion,
    createdAt,
    updatedAt,
  ];
}
