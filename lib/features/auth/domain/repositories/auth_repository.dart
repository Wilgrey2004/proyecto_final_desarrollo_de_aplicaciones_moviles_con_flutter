// lib\features\auth\domain\repositories\auth_repository.dart
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_model.dart';
import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<({Failure? failure, AuthResult? result})> login(LoginRequest request);
  Future<({Failure? failure, AuthResult? result})> register(
    RegisterRequest request,
  );
  Future<({Failure? failure, bool success})> forgotPassword(String email);
  Future<({Failure? failure, bool success})> changePassword(
    ChangePasswordRequest request,
  );
  Future<({Failure? failure, UserModel? user})> getCurrentUser();
  Future<({Failure? failure, bool success})> logout();
  Future<({Failure? failure, bool success})> checkAuthStatus();
}
