// lib\core\widgets\custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../shared/models/user_model.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isAuthenticated = state is AuthAuthenticated;
        final UserModel? user = isAuthenticated ? state.user : null;

        return Drawer(
          child: Column(
            children: [
              _buildHeader(context, user, isAuthenticated),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home,
                      title: 'Inicio',
                      route: '/',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info,
                      title: 'Sobre Nosotros',
                      route: '/about-us',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.room_service,
                      title: 'Servicios',
                      route: '/services',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.newspaper,
                      title: 'Noticias Ambientales',
                      route: '/news',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.video_library,
                      title: 'Videos Educativos',
                      route: '/videos',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.nature,
                      title: 'Áreas Protegidas',
                      route: '/protected-areas',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.map,
                      title: 'Mapa de Áreas',
                      route: '/areas-map',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.eco,
                      title: 'Medidas Ambientales',
                      route: '/environmental-measures',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.group,
                      title: 'Equipo del Ministerio',
                      route: '/team',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.volunteer_activism,
                      title: 'Voluntariado',
                      route: '/volunteer',
                    ),

                    // Authenticated sections
                    if (isAuthenticated) ...[
                      Divider(color: AppColors.divider),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Área Privada',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.policy,
                        title: 'Normativas Ambientales',
                        route: '/regulations',
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.report_problem,
                        title: 'Reportar Daño',
                        route: '/report-damage',
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.assignment,
                        title: 'Mis Reportes',
                        route: '/my-reports',
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.map_outlined,
                        title: 'Mapa de Reportes',
                        route: '/reports-map',
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.lock,
                        title: 'Cambiar Contraseña',
                        route: '/change-password',
                      ),
                    ],

                    Divider(color: AppColors.divider),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'Acerca de',
                      route: '/about',
                    ),
                  ],
                ),
              ),

              // Authentication section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: isAuthenticated
                    ? _buildLogoutButton(context)
                    : _buildLoginButton(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserModel? user,
    bool isAuthenticated,
  ) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.lightGreen],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: isAuthenticated && user?.avatar != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatar!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.primaryGreen,
                            );
                          },
                        ),
                      )
                    : Icon(Icons.eco, size: 30, color: AppColors.primaryGreen),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isAuthenticated
                          ? user?.fullName ?? 'Usuario'
                          : 'Ministerio de',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isAuthenticated ? user?.email ?? '' : 'Medio Ambiente',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            isAuthenticated ? 'Bienvenido de vuelta' : 'República Dominicana',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      dense: true,
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/login');
        },
        icon: Icon(Icons.login),
        label: Text('Iniciar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _showLogoutDialog(context);
        },
        icon: Icon(Icons.logout),
        label: Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutRequested());
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
