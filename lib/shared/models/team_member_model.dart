import 'package:equatable/equatable.dart';

class TeamMemberModel extends Equatable {
  final String id;
  final String nombre;
  final String apellido;
  final String cargo;
  final String? departamento;
  final String? email;
  final String? telefono;
  final String? foto;
  final String? biografia;
  final List<String> especialidades;
  final int? anosExperiencia;
  final String? educacion;
  final List<String> logros;
  final bool activo;
  final DateTime? fechaIngreso;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeamMemberModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.cargo,
    this.departamento,
    this.email,
    this.telefono,
    this.foto,
    this.biografia,
    this.especialidades = const [],
    this.anosExperiencia,
    this.educacion,
    this.logros = const [],
    this.activo = true,
    this.fechaIngreso,
    required this.createdAt,
    this.updatedAt,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      cargo: json['cargo'] ?? '',
      departamento: json['departamento'],
      email: json['email'],
      telefono: json['telefono'],
      foto: json['foto'],
      biografia: json['biografia'],
      especialidades: json['especialidades'] != null
          ? List<String>.from(
              json['especialidades']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      anosExperiencia: json['anos_experiencia'],
      educacion: json['educacion'],
      logros: json['logros'] != null
          ? List<String>.from(
              json['logros']
                  .toString()
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            )
          : [],
      activo: json['activo'] == 1 || json['activo'] == true,
      fechaIngreso: json['fecha_ingreso'] != null
          ? DateTime.tryParse(json['fecha_ingreso'])
          : null,
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
      'nombre': nombre,
      'apellido': apellido,
      'cargo': cargo,
      'departamento': departamento,
      'email': email,
      'telefono': telefono,
      'foto': foto,
      'biografia': biografia,
      'especialidades': especialidades.join(','),
      'anos_experiencia': anosExperiencia,
      'educacion': educacion,
      'logros': logros.join('\n'),
      'activo': activo,
      'fecha_ingreso': fechaIngreso?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$nombre $apellido';

  String get experienceText {
    if (anosExperiencia == null) return 'Experiencia no especificada';
    if (anosExperiencia! == 1) return '1 año de experiencia';
    return '$anosExperiencia años de experiencia';
  }

  String get joinDateText {
    if (fechaIngreso == null) return 'Fecha de ingreso no especificada';

    final now = DateTime.now();
    final difference = now.difference(fechaIngreso!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'En el ministerio desde hace ${years} año${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'En el ministerio desde hace ${months} mes${months > 1 ? 'es' : ''}';
    } else {
      return 'Recientemente incorporado';
    }
  }

  TeamMemberModel copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? cargo,
    String? departamento,
    String? email,
    String? telefono,
    String? foto,
    String? biografia,
    List<String>? especialidades,
    int? anosExperiencia,
    String? educacion,
    List<String>? logros,
    bool? activo,
    DateTime? fechaIngreso,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamMemberModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      cargo: cargo ?? this.cargo,
      departamento: departamento ?? this.departamento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      foto: foto ?? this.foto,
      biografia: biografia ?? this.biografia,
      especialidades: especialidades ?? this.especialidades,
      anosExperiencia: anosExperiencia ?? this.anosExperiencia,
      educacion: educacion ?? this.educacion,
      logros: logros ?? this.logros,
      activo: activo ?? this.activo,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    apellido,
    cargo,
    departamento,
    email,
    telefono,
    foto,
    biografia,
    especialidades,
    anosExperiencia,
    educacion,
    logros,
    activo,
    fechaIngreso,
    createdAt,
    updatedAt,
  ];
}
