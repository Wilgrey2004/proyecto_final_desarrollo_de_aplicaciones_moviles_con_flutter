// lib/shared/models/damage_report_model.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

class DamageReportModel extends Equatable {
  final String? id;
  final String titulo;
  final String descripcion;
  final String? fotoBase64;
  final String? fotoPath; // For local file path
  final double latitud;
  final double longitud;
  final String? ubicacionDescripcion;
  final String? categoria;
  final String? gravedad; // Baja, Media, Alta, Crítica
  final String estado; // Pendiente, En Proceso, Resuelto, Rechazado
  final String? comentarioMinisterio;
  final String? usuarioId;
  final String? codigoReporte;
  final DateTime fechaReporte;
  final DateTime? fechaActualizacion;

  const DamageReportModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    this.fotoBase64,
    this.fotoPath,
    required this.latitud,
    required this.longitud,
    this.ubicacionDescripcion,
    this.categoria,
    this.gravedad,
    this.estado = 'Pendiente',
    this.comentarioMinisterio,
    this.usuarioId,
    this.codigoReporte,
    required this.fechaReporte,
    this.fechaActualizacion,
  });

  factory DamageReportModel.fromJson(Map<String, dynamic> json) {
    return DamageReportModel(
      id: json['id']?.toString(),
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fotoBase64: json['foto'],
      latitud: double.tryParse(json['latitud']?.toString() ?? '0') ?? 0.0,
      longitud: double.tryParse(json['longitud']?.toString() ?? '0') ?? 0.0,
      ubicacionDescripcion: json['ubicacion_descripcion'],
      categoria: json['categoria'],
      gravedad: json['gravedad'],
      estado: json['estado'] ?? 'Pendiente',
      comentarioMinisterio: json['comentario_ministerio'],
      usuarioId: json['usuario_id']?.toString(),
      codigoReporte: json['codigo_reporte'],
      fechaReporte: json['fecha_reporte'] != null
          ? DateTime.tryParse(json['fecha_reporte']) ?? DateTime.now()
          : DateTime.now(),
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.tryParse(json['fecha_actualizacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      if (fotoBase64 != null) 'foto': fotoBase64,
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      if (ubicacionDescripcion != null)
        'ubicacion_descripcion': ubicacionDescripcion,
      if (categoria != null) 'categoria': categoria,
      if (gravedad != null) 'gravedad': gravedad,
      'estado': estado,
      if (comentarioMinisterio != null)
        'comentario_ministerio': comentarioMinisterio,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (codigoReporte != null) 'codigo_reporte': codigoReporte,
      'fecha_reporte': fechaReporte.toIso8601String(),
      if (fechaActualizacion != null)
        'fecha_actualizacion': fechaActualizacion!.toIso8601String(),
    };
  }

  String get coordenadasText =>
      '${latitud.toStringAsFixed(6)}, ${longitud.toStringAsFixed(6)}';

  String get fechaText {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${fechaReporte.day} ${months[fechaReporte.month - 1]} ${fechaReporte.year}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(fechaReporte);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  DamageReportModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? fotoBase64,
    String? fotoPath,
    double? latitud,
    double? longitud,
    String? ubicacionDescripcion,
    String? categoria,
    String? gravedad,
    String? estado,
    String? comentarioMinisterio,
    String? usuarioId,
    String? codigoReporte,
    DateTime? fechaReporte,
    DateTime? fechaActualizacion,
  }) {
    return DamageReportModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      fotoPath: fotoPath ?? this.fotoPath,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      ubicacionDescripcion: ubicacionDescripcion ?? this.ubicacionDescripcion,
      categoria: categoria ?? this.categoria,
      gravedad: gravedad ?? this.gravedad,
      estado: estado ?? this.estado,
      comentarioMinisterio: comentarioMinisterio ?? this.comentarioMinisterio,
      usuarioId: usuarioId ?? this.usuarioId,
      codigoReporte: codigoReporte ?? this.codigoReporte,
      fechaReporte: fechaReporte ?? this.fechaReporte,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    fotoBase64,
    fotoPath,
    latitud,
    longitud,
    ubicacionDescripcion,
    categoria,
    gravedad,
    estado,
    comentarioMinisterio,
    usuarioId,
    codigoReporte,
    fechaReporte,
    fechaActualizacion,
  ];
}
