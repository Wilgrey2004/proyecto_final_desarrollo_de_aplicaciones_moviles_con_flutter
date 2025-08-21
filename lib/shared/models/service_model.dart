import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String? imagen;
  final String? icono;
  final String? url;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.imagen,
    this.icono,
    this.url,
    this.activo = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'],
      icono: json['icono'],
      url: json['url'],
      activo: json['activo'] == 1 || json['activo'] == true,
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
      'icono': icono,
      'url': url,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? imagen,
    String? icono,
    String? url,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagen: imagen ?? this.imagen,
      icono: icono ?? this.icono,
      url: url ?? this.url,
      activo: activo ?? this.activo,
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
    icono,
    url,
    activo,
    createdAt,
    updatedAt,
  ];
}
