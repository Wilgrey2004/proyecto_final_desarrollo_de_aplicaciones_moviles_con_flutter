// lib/features/user_reports/presentation/pages/my_reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/damage_report_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class MyReportsPage extends StatefulWidget {
  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<DamageReportModel> _reports = [];
  List<DamageReportModel> _filteredReports = [];
  List<String> _estados = [];
  String _selectedEstado = 'Todos';
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  final List<String> _estadosOptions = [
    'Todos',
    'Pendiente',
    'En Proceso',
    'Resuelto',
    'Rechazado',
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  void _checkAuthAndLoad() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _loadMyReports();
    } else {
      _showAuthRequiredDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reportes'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ReportSearchDelegate(_reports),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/report-damage');
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            _showAuthRequiredDialog();
          }
        },
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/report-damage');
        },
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Nuevo Reporte'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidget(message: 'Cargando tus reportes...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadMyReports,
      );
    }

    if (_reports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMyReports,
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _filteredReports.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = _filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightGreen, AppColors.primaryGreen],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Reportes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Seguimiento de tus reportes ambientales',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lock, color: Colors.white, size: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${_filteredReports.length} reporte${_filteredReports.length != 1 ? 's' : ''} encontrado${_filteredReports.length != 1 ? 's' : ''}${_searchQuery.isNotEmpty || _selectedEstado != 'Todos' ? ' (filtrado${_filteredReports.length != 1 ? 's' : ''})' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar reportes...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedEstado,
        decoration: InputDecoration(
          labelText: 'Estado',
          prefixIcon: Icon(Icons.filter_list, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: _estadosOptions.map((estado) {
          return DropdownMenuItem(
            value: estado,
            child: Row(
              children: [
                if (estado != 'Todos') _buildStatusIcon(estado),
                if (estado != 'Todos') SizedBox(width: 8),
                Text(estado, style: TextStyle(fontSize: 14)),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _onEstadoChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildReportCard(DamageReportModel report) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReportDetail(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildStatusChip(report.estado),
                ],
              ),
              SizedBox(height: 8),
              Text(
                report.descripcion,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    text: report.categoria ?? 'Sin categoría',
                    color: AppColors.primaryGreen,
                    isSmall: true,
                  ),
                  SizedBox(width: 8),
                  if (report.gravedad != null)
                    _buildGravityChip(report.gravedad!),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                  SizedBox(width: 4),
                  Text(
                    report.fechaText,
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  SizedBox(width: 16),
                  if (report.codigoReporte != null) ...[
                    Icon(Icons.tag, size: 14, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Text(
                      report.codigoReporte!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String estado) {
    Color color;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        color = AppColors.warning;
        icon = Icons.schedule;
        break;
      case 'en proceso':
        color = AppColors.secondaryBlue;
        icon = Icons.refresh;
        break;
      case 'resuelto':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'rechazado':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textLight;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            estado,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String estado) {
    Color color;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        color = AppColors.warning;
        icon = Icons.schedule;
        break;
      case 'en proceso':
        color = AppColors.secondaryBlue;
        icon = Icons.refresh;
        break;
      case 'resuelto':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'rechazado':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textLight;
        icon = Icons.help;
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildGravityChip(String gravedad) {
    Color color;

    switch (gravedad.toLowerCase()) {
      case 'baja':
        color = AppColors.success;
        break;
      case 'media':
        color = AppColors.warning;
        break;
      case 'alta':
        color = Colors.orange;
        break;
      case 'crítica':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        gravedad,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No tienes reportes aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando reportes daños ambientales, aparecerán aquí para que puedas hacer seguimiento.',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/report-damage');
            },
            icon: Icon(Icons.add),
            label: Text('Crear Primer Reporte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No se encontraron reportes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda o cambia los filtros',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              _onEstadoChanged('Todos');
            },
            icon: Icon(Icons.clear),
            label: Text('Limpiar filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDetail(DamageReportModel report) {
    Navigator.pushNamed(context, '/report-detail', arguments: report.id);
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 60, color: AppColors.warning),
              SizedBox(height: 16),
              Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Necesitas iniciar sesión para ver tus reportes.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadMyReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(
        ApiConstants.myReports,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> reportsJson = response['data'];
        final reports = reportsJson
            .map((json) => DamageReportModel.fromJson(json))
            .toList();

        // Sort by date (newest first)
        reports.sort((a, b) => b.fechaReporte.compareTo(a.fechaReporte));

        // Extract estados
        final estados = reports
            .map((report) => report.estado)
            .where((estado) => estado.isNotEmpty)
            .toSet()
            .toList();
        estados.sort();

        setState(() {
          _reports = reports;
          _filteredReports = reports;
          _estados = ['Todos', ...estados];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar reportes';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Verifica tu internet.';
        _isLoading = false;
      });
    }
  }

  void _filterReports() {
    setState(() {
      List<DamageReportModel> filtered = _reports;

      // Filter by estado
      if (_selectedEstado != 'Todos') {
        filtered = filtered
            .where((report) => report.estado == _selectedEstado)
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((report) {
          return report.titulo.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              report.descripcion.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (report.codigoReporte?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false) ||
              (report.categoria?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }

      _filteredReports = filtered;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterReports();
  }

  void _onEstadoChanged(String estado) {
    _selectedEstado = estado;
    _filterReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}

class ReportSearchDelegate extends SearchDelegate<String> {
  final List<DamageReportModel> reports;

  ReportSearchDelegate(this.reports);

  @override
  String get searchFieldLabel => 'Buscar reportes...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Busca reportes por título, descripción o código',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredReports = reports.where((report) {
      return report.titulo.toLowerCase().contains(query.toLowerCase()) ||
          report.descripcion.toLowerCase().contains(query.toLowerCase()) ||
          (report.codigoReporte?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (report.categoria?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();

    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'No se encontraron resultados para "$query"',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(report.estado),
              child: Icon(
                _getStatusIcon(report.estado),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              report.titulo,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  report.estado,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(report.estado),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(report.fechaText, style: TextStyle(fontSize: 11)),
              ],
            ),
            trailing: report.codigoReporte != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.codigoReporte!,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              close(context, report.id ?? '');
              Navigator.pushNamed(
                context,
                '/report-detail',
                arguments: report.id,
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.warning;
      case 'en proceso':
        return AppColors.secondaryBlue;
      case 'resuelto':
        return AppColors.success;
      case 'rechazado':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule;
      case 'en proceso':
        return Icons.refresh;
      case 'resuelto':
        return Icons.check_circle;
      case 'rechazado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
