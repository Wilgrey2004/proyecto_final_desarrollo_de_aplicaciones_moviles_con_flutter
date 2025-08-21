// lib/shared/models/volunteer_application_model.dart
import 'package:equatable/equatable.dart';

class VolunteerApplicationModel extends Equatable {
  final String cedula;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String? motivacion;
  final List<String> areasInteres;
  final String? experienciaPrevia;
  final String? disponibilidad;
  final DateTime fechaSolicitud;

  const VolunteerApplicationModel({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    this.motivacion,
    this.areasInteres = const [],
    this.experienciaPrevia,
    this.disponibilidad,
    required this.fechaSolicitud,
  });

  factory VolunteerApplicationModel.fromJson(Map<String, dynamic> json) {
    return VolunteerApplicationModel(
      cedula: json['cedula'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      motivacion: json['motivacion'],
      areasInteres: json['areas_interes'] != null
          ? List<String>.from(
              json['areas_interes']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      experienciaPrevia: json['experiencia_previa'],
      disponibilidad: json['disponibilidad'],
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.tryParse(json['fecha_solicitud']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'motivacion': motivacion,
      'areas_interes': areasInteres.join(','),
      'experiencia_previa': experienciaPrevia,
      'disponibilidad': disponibilidad,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
    };
  }

  String get fullName => '$nombre $apellido';

  @override
  List<Object?> get props => [
    cedula,
    nombre,
    apellido,
    email,
    telefono,
    motivacion,
    areasInteres,
    experienciaPrevia,
    disponibilidad,
    fechaSolicitud,
  ];
}
