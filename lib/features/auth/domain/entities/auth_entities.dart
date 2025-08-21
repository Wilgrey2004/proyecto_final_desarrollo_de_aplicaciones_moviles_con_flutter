// lib\features\auth\domain\entities\auth_entities.dart
import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_model.dart';

class AuthResult extends Equatable {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  @override
  List<Object?> get props => [success, message, token, user];
}

class LoginRequest extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

class RegisterRequest extends Equatable {
  final String cedula;
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String telefono;

  const RegisterRequest({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
    required this.telefono,
  });

  @override
  List<Object> get props => [
    cedula,
    nombre,
    apellido,
    email,
    password,
    telefono,
  ];
}

class ChangePasswordRequest extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}
