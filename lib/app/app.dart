import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/colors.dart';
import '../core/network/api_client.dart';
import '../shared/services/storage_service.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'routes/app_routes.dart';

class MedioAmbienteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Crear las dependencias necesarias
    final apiClient = ApiClient();
    final storageService = StorageService();
    final authRepository = AuthRepositoryImpl(
      apiClient: apiClient,
      storageService: storageService,
    );

    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(authRepository)..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'Ministerio de Medio Ambiente',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: AppColors.primaryGreen,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
        initialRoute: '/',
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
