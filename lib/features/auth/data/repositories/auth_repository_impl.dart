// lib\features\auth\data\repositories\auth_repository_impl.dart
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final StorageService storageService;

  AuthRepositoryImpl({required this.apiClient, required this.storageService});

  @override
  Future<({Failure? failure, AuthResult? result})> login(
    LoginRequest request,
  ) async {
    try {
      final requestModel = LoginRequestModel(
        email: request.email,
        password: request.password,
        rememberMe: request.rememberMe,
      );

      final response = await apiClient.post(
        ApiConstants.login,
        requestModel.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response);

      if (authResponse.success &&
          authResponse.token != null &&
          authResponse.user != null) {
        // Save token and user data
        await storageService.saveToken(authResponse.token!);
        await storageService.saveUser(authResponse.user!);
        await storageService.setLoggedIn(true);

        if (request.rememberMe) {
          await storageService.setRememberMe(true);
          await storageService.saveLastEmail(request.email);
        }

        return (
          failure: null,
          result: AuthResult(
            success: true,
            message: authResponse.message,
            token: authResponse.token,
            user: authResponse.user,
          ),
        );
      } else {
        return (
          failure: null,
          result: AuthResult(success: false, message: authResponse.message),
        );
      }
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(e.message), result: null);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), result: null);
    } catch (e) {
      return (
        failure: GeneralFailure('Error inesperado durante el inicio de sesión'),
        result: null,
      );
    }
  }

  @override
  Future<({Failure? failure, AuthResult? result})> register(
    RegisterRequest request,
  ) async {
    try {
      final requestModel = RegisterRequestModel(
        cedula: request.cedula,
        nombre: request.nombre,
        apellido: request.apellido,
        email: request.email,
        password: request.password,
        telefono: request.telefono,
      );

      final response = await apiClient.post(
        ApiConstants.register,
        requestModel.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response);

      return (
        failure: null,
        result: AuthResult(
          success: authResponse.success,
          message: authResponse.message,
          token: authResponse.token,
          user: authResponse.user,
        ),
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(e.message), result: null);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), result: null);
    } catch (e) {
      return (
        failure: GeneralFailure('Error inesperado durante el registro'),
        result: null,
      );
    }
  }

  @override
  Future<({Failure? failure, bool success})> forgotPassword(
    String email,
  ) async {
    try {
      final requestModel = ForgotPasswordRequestModel(email: email);

      final response = await apiClient.post(
        ApiConstants.forgotPassword,
        requestModel.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response);
      return (failure: null, success: authResponse.success);
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(e.message), success: false);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), success: false);
    } catch (e) {
      return (
        failure: GeneralFailure('Error inesperado al recuperar contraseña'),
        success: false,
      );
    }
  }

  @override
  Future<({Failure? failure, bool success})> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final requestModel = ChangePasswordRequestModel(
        currentPassword: request.currentPassword,
        newPassword: request.newPassword,
        confirmPassword: request.confirmPassword,
      );

      final response = await apiClient.post(
        ApiConstants.changePassword,
        requestModel.toJson(),
        requiresAuth: true,
      );

      final authResponse = AuthResponseModel.fromJson(response);
      return (failure: null, success: authResponse.success);
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(e.message), success: false);
    } on ServerException catch (e) {
      return (failure: ServerFailure(e.message), success: false);
    } catch (e) {
      return (
        failure: GeneralFailure('Error inesperado al cambiar contraseña'),
        success: false,
      );
    }
  }

  @override
  Future<({Failure? failure, UserModel? user})> getCurrentUser() async {
    try {
      final user = await storageService.getUser();
      return (failure: null, user: user);
    } catch (e) {
      return (
        failure: CacheFailure('Error al obtener datos del usuario'),
        user: null,
      );
    }
  }

  @override
  Future<({Failure? failure, bool success})> logout() async {
    try {
      await storageService.clearAll();
      return (failure: null, success: true);
    } catch (e) {
      return (failure: CacheFailure('Error al cerrar sesión'), success: false);
    }
  }

  @override
  Future<({Failure? failure, bool success})> checkAuthStatus() async {
    try {
      final isLoggedIn = await storageService.isLoggedIn();
      final token = await storageService.getToken();

      return (failure: null, success: isLoggedIn && token != null);
    } catch (e) {
      return (
        failure: CacheFailure('Error al verificar estado de autenticación'),
        success: false,
      );
    }
  }
}
