import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String cedula;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$nombre $apellido';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      cedula: json['cedula'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      avatar: json['avatar'],
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
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? cedula,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cedula,
    nombre,
    apellido,
    email,
    telefono,
    avatar,
    createdAt,
    updatedAt,
  ];
}
