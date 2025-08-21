// lib/shared/models/regulation_model.dart
import 'package:equatable/equatable.dart';

class RegulationModel extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo; // Ley, Decreto, Resolución, Reglamento
  final String numero;
  final String? codigoOficial;
  final DateTime? fechaPromulgacion;
  final String? organismo; // Ministerio, Congreso, Presidencia
  final String? ambito; // Nacional, Regional, Municipal
  final List<String> temas; // Agua, Aire, Biodiversidad, etc.
  final String? documentoUrl;
  final String? resumen;
  final String estado; // Vigente, Derogada, Modificada
  final bool destacada;
  final int descargas;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RegulationModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.numero,
    this.codigoOficial,
    this.fechaPromulgacion,
    this.organismo,
    this.ambito,
    this.temas = const [],
    this.documentoUrl,
    this.resumen,
    this.estado = 'Vigente',
    this.destacada = false,
    this.descargas = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory RegulationModel.fromJson(Map<String, dynamic> json) {
    return RegulationModel(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipo: json['tipo'] ?? '',
      numero: json['numero'] ?? '',
      codigoOficial: json['codigo_oficial'],
      fechaPromulgacion: json['fecha_promulgacion'] != null
          ? DateTime.tryParse(json['fecha_promulgacion'])
          : null,
      organismo: json['organismo'],
      ambito: json['ambito'],
      temas: json['temas'] != null
          ? List<String>.from(
              json['temas']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      documentoUrl: json['documento_url'],
      resumen: json['resumen'],
      estado: json['estado'] ?? 'Vigente',
      destacada: json['destacada'] == 1 || json['destacada'] == true,
      descargas: json['descargas'] ?? 0,
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
      'tipo': tipo,
      'numero': numero,
      'codigo_oficial': codigoOficial,
      'fecha_promulgacion': fechaPromulgacion?.toIso8601String(),
      'organismo': organismo,
      'ambito': ambito,
      'temas': temas.join(','),
      'documento_url': documentoUrl,
      'resumen': resumen,
      'estado': estado,
      'destacada': destacada,
      'descargas': descargas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullTitle => '$tipo $numero: $titulo';

  String get dateText {
    if (fechaPromulgacion == null) return 'Fecha no especificada';

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${fechaPromulgacion!.day} de ${months[fechaPromulgacion!.month - 1]} de ${fechaPromulgacion!.year}';
  }

  String get downloadText {
    if (descargas == 0) return 'Sin descargas';
    if (descargas == 1) return '1 descarga';
    return '$descargas descargas';
  }

  RegulationModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? numero,
    String? codigoOficial,
    DateTime? fechaPromulgacion,
    String? organismo,
    String? ambito,
    List<String>? temas,
    String? documentoUrl,
    String? resumen,
    String? estado,
    bool? destacada,
    int? descargas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegulationModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      numero: numero ?? this.numero,
      codigoOficial: codigoOficial ?? this.codigoOficial,
      fechaPromulgacion: fechaPromulgacion ?? this.fechaPromulgacion,
      organismo: organismo ?? this.organismo,
      ambito: ambito ?? this.ambito,
      temas: temas ?? this.temas,
      documentoUrl: documentoUrl ?? this.documentoUrl,
      resumen: resumen ?? this.resumen,
      estado: estado ?? this.estado,
      destacada: destacada ?? this.destacada,
      descargas: descargas ?? this.descargas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    tipo,
    numero,
    codigoOficial,
    fechaPromulgacion,
    organismo,
    ambito,
    temas,
    documentoUrl,
    resumen,
    estado,
    destacada,
    descargas,
    createdAt,
    updatedAt,
  ];
}
