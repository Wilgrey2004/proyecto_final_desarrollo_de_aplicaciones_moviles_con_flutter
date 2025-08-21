// lib\features\auth\presentation\bloc\auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_model.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

class RegisterRequested extends AuthEvent {
  final String cedula;
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String telefono;

  const RegisterRequested({
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

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  const AuthAuthenticated({required this.user, required this.token});

  @override
  List<Object> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.checkAuthStatus();

    if (result.failure != null) {
      emit(AuthUnauthenticated());
      return;
    }

    if (result.success) {
      final userResult = await authRepository.getCurrentUser();
      if (userResult.failure != null) {
        emit(AuthUnauthenticated());
      } else if (userResult.user != null) {
        emit(AuthAuthenticated(user: userResult.user!, token: ''));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final request = LoginRequest(
      email: event.email,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    final result = await authRepository.login(request);

    if (result.failure != null) {
      emit(AuthError(message: result.failure!.message));
    } else if (result.result != null) {
      final authResult = result.result!;
      if (authResult.success &&
          authResult.user != null &&
          authResult.token != null) {
        emit(
          AuthAuthenticated(user: authResult.user!, token: authResult.token!),
        );
      } else {
        emit(AuthError(message: authResult.message));
      }
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final request = RegisterRequest(
      cedula: event.cedula,
      nombre: event.nombre,
      apellido: event.apellido,
      email: event.email,
      password: event.password,
      telefono: event.telefono,
    );

    final result = await authRepository.register(request);

    if (result.failure != null) {
      emit(AuthError(message: result.failure!.message));
    } else if (result.result != null) {
      final authResult = result.result!;
      if (authResult.success) {
        emit(AuthSuccess(message: authResult.message));
      } else {
        emit(AuthError(message: authResult.message));
      }
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.forgotPassword(event.email);

    if (result.failure != null) {
      emit(AuthError(message: result.failure!.message));
    } else if (result.success) {
      emit(
        AuthSuccess(message: 'Instrucciones enviadas a tu correo electrónico'),
      );
    } else {
      emit(AuthError(message: 'Error al enviar instrucciones'));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final request = ChangePasswordRequest(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    final result = await authRepository.changePassword(request);

    if (result.failure != null) {
      emit(AuthError(message: result.failure!.message));
    } else if (result.success) {
      emit(AuthSuccess(message: 'Contraseña cambiada exitosamente'));
    } else {
      emit(AuthError(message: 'Error al cambiar contraseña'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
