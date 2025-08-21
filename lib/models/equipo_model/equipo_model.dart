import 'dart:convert';

class EquipoModel {
  // ignore: non_constant_identifier_names
  String? id, nombre, cargo, departamento, foto, biografia, fecha_Creacion;
  int? orden;

  EquipoModel({
    this.id,
    this.nombre,
    this.cargo,
    this.departamento,
    this.foto,
    this.biografia,
    this.orden,
    // ignore: non_constant_identifier_names
    this.fecha_Creacion,
  });

  factory EquipoModel.forMap(Map<String, dynamic> m) => EquipoModel(
    id: m['id'],
    nombre: m['nombre'],
    cargo: m['cargo'],
    departamento: m['departamento'],
    foto: m['foto'],
    biografia: m['biografia'],
    orden: (m['orden'] as num?)?.toInt(),
    fecha_Creacion: m['fecha_creacion'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cargo': cargo,
    'departamento': departamento,
    'foto': foto,
    'biografia': biografia,
    'orden': orden,
    'fecha_creacion': fecha_Creacion,
  };

  static List<EquipoModel> listFromJson(String body) {
    final data = json.decode(body) as List;
    return data.map((e) => EquipoModel.forMap(e)).toList();
  }
}
