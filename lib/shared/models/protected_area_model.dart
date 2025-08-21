import 'package:equatable/equatable.dart';

class ProtectedAreaModel extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final String tipo; // Parque Nacional, Reserva Natural, etc.
  final String provincia;
  final String municipio;
  final double latitud;
  final double longitud;
  final double? superficie; // en hectáreas
  final String? imagen;
  final List<String> imagenes;
  final String? sitioWeb;
  final String? telefono;
  final String? horarios;
  final String? tarifas;
  final List<String> actividades;
  final List<String> flora;
  final List<String> fauna;
  final String? climaRecomendado;
  final String? comoLlegar;
  final bool visitasPermitidas;
  final DateTime fechaCreacion;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProtectedAreaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.provincia,
    required this.municipio,
    required this.latitud,
    required this.longitud,
    this.superficie,
    this.imagen,
    this.imagenes = const [],
    this.sitioWeb,
    this.telefono,
    this.horarios,
    this.tarifas,
    this.actividades = const [],
    this.flora = const [],
    this.fauna = const [],
    this.climaRecomendado,
    this.comoLlegar,
    this.visitasPermitidas = true,
    required this.fechaCreacion,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProtectedAreaModel.fromJson(Map<String, dynamic> json) {
    return ProtectedAreaModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipo: json['tipo'] ?? '',
      provincia: json['provincia'] ?? '',
      municipio: json['municipio'] ?? '',
      latitud: _parseDouble(json['latitud']) ?? 0.0,
      longitud: _parseDouble(json['longitud']) ?? 0.0,
      superficie: _parseDouble(json['superficie']),
      imagen: json['imagen'],
      imagenes: json['imagenes'] != null
          ? List<String>.from(
              json['imagenes']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      sitioWeb: json['sitio_web'],
      telefono: json['telefono'],
      horarios: json['horarios'],
      tarifas: json['tarifas'],
      actividades: json['actividades'] != null
          ? List<String>.from(
              json['actividades']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      flora: json['flora'] != null
          ? List<String>.from(
              json['flora']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      fauna: json['fauna'] != null
          ? List<String>.from(
              json['fauna']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      climaRecomendado: json['clima_recomendado'],
      comoLlegar: json['como_llegar'],
      visitasPermitidas:
          json['visitas_permitidas'] == 1 || json['visitas_permitidas'] == true,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion']) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'provincia': provincia,
      'municipio': municipio,
      'latitud': latitud,
      'longitud': longitud,
      'superficie': superficie,
      'imagen': imagen,
      'imagenes': imagenes.join(','),
      'sitio_web': sitioWeb,
      'telefono': telefono,
      'horarios': horarios,
      'tarifas': tarifas,
      'actividades': actividades.join(','),
      'flora': flora.join(','),
      'fauna': fauna.join(','),
      'clima_recomendado': climaRecomendado,
      'como_llegar': comoLlegar,
      'visitas_permitidas': visitasPermitidas,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get ubicacion => '$municipio, $provincia';

  String get superficieFormatted {
    if (superficie == null) return 'No especificada';
    if (superficie! >= 10000) {
      return '${(superficie! / 10000).toStringAsFixed(1)} km²';
    }
    return '${superficie!.toStringAsFixed(0)} hectáreas';
  }

  ProtectedAreaModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? tipo,
    String? provincia,
    String? municipio,
    double? latitud,
    double? longitud,
    double? superficie,
    String? imagen,
    List<String>? imagenes,
    String? sitioWeb,
    String? telefono,
    String? horarios,
    String? tarifas,
    List<String>? actividades,
    List<String>? flora,
    List<String>? fauna,
    String? climaRecomendado,
    String? comoLlegar,
    bool? visitasPermitidas,
    DateTime? fechaCreacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProtectedAreaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      provincia: provincia ?? this.provincia,
      municipio: municipio ?? this.municipio,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      superficie: superficie ?? this.superficie,
      imagen: imagen ?? this.imagen,
      imagenes: imagenes ?? this.imagenes,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      telefono: telefono ?? this.telefono,
      horarios: horarios ?? this.horarios,
      tarifas: tarifas ?? this.tarifas,
      actividades: actividades ?? this.actividades,
      flora: flora ?? this.flora,
      fauna: fauna ?? this.fauna,
      climaRecomendado: climaRecomendado ?? this.climaRecomendado,
      comoLlegar: comoLlegar ?? this.comoLlegar,
      visitasPermitidas: visitasPermitidas ?? this.visitasPermitidas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    tipo,
    provincia,
    municipio,
    latitud,
    longitud,
    superficie,
    imagen,
    imagenes,
    sitioWeb,
    telefono,
    horarios,
    tarifas,
    actividades,
    flora,
    fauna,
    climaRecomendado,
    comoLlegar,
    visitasPermitidas,
    fechaCreacion,
    createdAt,
    updatedAt,
  ];
}
