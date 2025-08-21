// lib/features/regulations/presentation/pages/regulations_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/regulation_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class RegulationsPage extends StatefulWidget {
  @override
  _RegulationsPageState createState() => _RegulationsPageState();
}

class _RegulationsPageState extends State<RegulationsPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<RegulationModel> _regulations = [];
  List<RegulationModel> _filteredRegulations = [];
  List<String> _types = [];
  List<String> _topics = [];
  String _selectedType = 'Todos';
  String _selectedTopic = 'Todos';
  String _selectedStatus = 'Todos';
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  final List<String> _statusOptions = [
    'Todos',
    'Vigente',
    'Derogada',
    'Modificada',
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  void _checkAuthAndLoad() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _loadRegulations();
    } else {
      _showAuthRequiredDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Normativas Ambientales'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RegulationSearchDelegate(_regulations),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
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
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidget(message: 'Cargando normativas ambientales...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadRegulations,
      );
    }

    if (_regulations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadRegulations,
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _filteredRegulations.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredRegulations.length,
                    itemBuilder: (context, index) {
                      final regulation = _filteredRegulations[index];
                      if (index == 0 &&
                          regulation.destacada &&
                          _searchQuery.isEmpty &&
                          _selectedType == 'Todos' &&
                          _selectedTopic == 'Todos' &&
                          _selectedStatus == 'Todos') {
                        return _buildFeaturedRegulationCard(regulation);
                      }
                      return _buildRegulationCard(regulation);
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
              Icon(Icons.policy, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marco Legal Ambiental',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Leyes, decretos y regulaciones ambientales',
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
            '${_filteredRegulations.length} normativa${_filteredRegulations.length != 1 ? 's' : ''} disponible${_filteredRegulations.length != 1 ? 's' : ''}${_searchQuery.isNotEmpty || _selectedType != 'Todos' || _selectedTopic != 'Todos' || _selectedStatus != 'Todos' ? ' (filtrada${_filteredRegulations.length != 1 ? 's' : ''})' : ''}',
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
          hintText: 'Buscar normativas...',
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
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _onTypeChanged(value);
                }
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedTopic,
              decoration: InputDecoration(
                labelText: 'Tema',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _topics.map((topic) {
                return DropdownMenuItem(
                  value: topic,
                  child: Text(topic, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _onTopicChanged(value);
                }
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _onStatusChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRegulationCard(RegulationModel regulation) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showRegulationDetail(regulation),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.lightGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DESTACADA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    _buildStatusChip(regulation.estado),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  regulation.fullTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  regulation.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.category,
                      text: regulation.tipo,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 8),
                    if (regulation.organismo != null)
                      _buildInfoChip(
                        icon: Icons.account_balance,
                        text: regulation.organismo!,
                        color: AppColors.secondaryBlue,
                      ),
                  ],
                ),
                if (regulation.fechaPromulgacion != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        regulation.dateText,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.download,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        regulation.downloadText,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegulationCard(RegulationModel regulation) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRegulationDetail(regulation),
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
                      regulation.fullTitle,
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
                  _buildStatusChip(regulation.estado, isSmall: true),
                ],
              ),
              SizedBox(height: 8),
              Text(
                regulation.descripcion,
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
                    text: regulation.tipo,
                    color: AppColors.primaryGreen,
                    isSmall: true,
                  ),
                  SizedBox(width: 8),
                  if (regulation.temas.isNotEmpty) ...[
                    _buildInfoChip(
                      icon: Icons.topic,
                      text: regulation.temas.first,
                      color: AppColors.secondaryBlue,
                      isSmall: true,
                    ),
                    if (regulation.temas.length > 1) ...[
                      SizedBox(width: 4),
                      Text(
                        '+${regulation.temas.length - 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, {bool isSmall = false}) {
    Color color;
    switch (status.toLowerCase()) {
      case 'vigente':
        color = AppColors.success;
        break;
      case 'derogada':
        color = AppColors.error;
        break;
      case 'modificada':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.textLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
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
          Icon(Icons.policy_outlined, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No hay normativas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las normativas ambientales se mostrarán aquí cuando estén disponibles.',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRegulations,
            icon: Icon(Icons.refresh),
            label: Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
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
            'No se encontraron normativas',
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
              _onTypeChanged('Todos');
              _onTopicChanged('Todos');
              _onStatusChanged('Todos');
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

  void _showRegulationDetail(RegulationModel regulation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRegulationDetailSheet(regulation),
    );
  }

  Widget _buildRegulationDetailSheet(RegulationModel regulation) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      regulation.fullTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusChip(regulation.estado),
                ],
              ),
              SizedBox(height: 16),
              Text(
                regulation.descripcion,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
              if (regulation.resumen != null) ...[
                _buildDetailSection('Resumen', regulation.resumen!),
                SizedBox(height: 16),
              ],
              if (regulation.organismo != null) ...[
                _buildDetailSection('Organismo Emisor', regulation.organismo!),
                SizedBox(height: 16),
              ],
              if (regulation.ambito != null) ...[
                _buildDetailSection('Ámbito de Aplicación', regulation.ambito!),
                SizedBox(height: 16),
              ],
              if (regulation.fechaPromulgacion != null) ...[
                _buildDetailSection(
                  'Fecha de Promulgación',
                  regulation.dateText,
                ),
                SizedBox(height: 16),
              ],
              if (regulation.temas.isNotEmpty) ...[
                _buildDetailSection('Temas', regulation.temas.join(', ')),
                SizedBox(height: 16),
              ],
              if (regulation.codigoOficial != null) ...[
                _buildDetailSection(
                  'Código Oficial',
                  regulation.codigoOficial!,
                ),
                SizedBox(height: 16),
              ],
              _buildDetailSection('Descargas', regulation.downloadText),
              SizedBox(height: 24),
              if (regulation.documentoUrl != null)
                _buildActionButtons(regulation),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RegulationModel regulation) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadDocument(regulation),
            icon: Icon(Icons.download, size: 18),
            label: Text('Descargar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewDocument(regulation),
            icon: Icon(Icons.visibility, size: 18),
            label: Text('Ver Online'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
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
                'Necesitas iniciar sesión para acceder a las normativas ambientales.',
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text('Información'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marco Legal Ambiental',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Esta sección contiene el conjunto de leyes, decretos, resoluciones y reglamentos que regulan la protección del medio ambiente en República Dominicana.',
                style: TextStyle(height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                'Tipos de Normativas:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '• Leyes del Congreso Nacional\n• Decretos del Poder Ejecutivo\n• Resoluciones ministeriales\n• Reglamentos de aplicación',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadDocument(RegulationModel regulation) async {
    if (regulation.documentoUrl != null) {
      final Uri documentUri = Uri.parse(regulation.documentoUrl!);
      if (await canLaunchUrl(documentUri)) {
        await launchUrl(documentUri, mode: LaunchMode.externalApplication);
        // TODO: Increment download count via API
      }
    }
  }

  Future<void> _viewDocument(RegulationModel regulation) async {
    if (regulation.documentoUrl != null) {
      final Uri documentUri = Uri.parse(regulation.documentoUrl!);
      if (await canLaunchUrl(documentUri)) {
        await launchUrl(documentUri, mode: LaunchMode.inAppWebView);
      }
    }
  }

  Future<void> _loadRegulations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(
        ApiConstants.regulations,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> regulationsJson = response['data'];
        final regulations = regulationsJson
            .map((json) => RegulationModel.fromJson(json))
            .toList();

        // Sort: featured first, then by date
        regulations.sort((a, b) {
          if (a.destacada && !b.destacada) return -1;
          if (!a.destacada && b.destacada) return 1;

          if (a.fechaPromulgacion != null && b.fechaPromulgacion != null) {
            return b.fechaPromulgacion!.compareTo(a.fechaPromulgacion!);
          }

          return b.createdAt.compareTo(a.createdAt);
        });

        // Extract types and topics
        final types = regulations
            .map((reg) => reg.tipo)
            .where((type) => type.isNotEmpty)
            .toSet()
            .toList();
        types.sort();

        final topics = regulations
            .expand((reg) => reg.temas)
            .where((topic) => topic.isNotEmpty)
            .toSet()
            .toList();
        topics.sort();

        setState(() {
          _regulations = regulations;
          _filteredRegulations = regulations;
          _types = ['Todos', ...types];
          _topics = ['Todos', ...topics];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar normativas';
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

  void _filterRegulations() {
    setState(() {
      List<RegulationModel> filtered = _regulations;

      // Filter by type
      if (_selectedType != 'Todos') {
        filtered = filtered.where((reg) => reg.tipo == _selectedType).toList();
      }

      // Filter by topic
      if (_selectedTopic != 'Todos') {
        filtered = filtered
            .where((reg) => reg.temas.contains(_selectedTopic))
            .toList();
      }

      // Filter by status
      if (_selectedStatus != 'Todos') {
        filtered = filtered
            .where((reg) => reg.estado == _selectedStatus)
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((reg) {
          return reg.titulo.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              reg.descripcion.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              reg.numero.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (reg.codigoOficial?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false) ||
              reg.temas.any(
                (tema) =>
                    tema.toLowerCase().contains(_searchQuery.toLowerCase()),
              );
        }).toList();
      }

      _filteredRegulations = filtered;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterRegulations();
  }

  void _onTypeChanged(String type) {
    _selectedType = type;
    _filterRegulations();
  }

  void _onTopicChanged(String topic) {
    _selectedTopic = topic;
    _filterRegulations();
  }

  void _onStatusChanged(String status) {
    _selectedStatus = status;
    _filterRegulations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}

class RegulationSearchDelegate extends SearchDelegate<String> {
  final List<RegulationModel> regulations;

  RegulationSearchDelegate(this.regulations);

  @override
  String get searchFieldLabel => 'Buscar normativas...';

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
              'Busca normativas por título, número o tema',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredRegulations = regulations.where((regulation) {
      return regulation.titulo.toLowerCase().contains(query.toLowerCase()) ||
          regulation.descripcion.toLowerCase().contains(query.toLowerCase()) ||
          regulation.numero.toLowerCase().contains(query.toLowerCase()) ||
          (regulation.codigoOficial?.toLowerCase().contains(
                query.toLowerCase(),
              ) ??
              false) ||
          regulation.temas.any(
            (tema) => tema.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

    if (filteredRegulations.isEmpty) {
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
      itemCount: filteredRegulations.length,
      itemBuilder: (context, index) {
        final regulation = filteredRegulations[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.policy, color: Colors.white),
            ),
            title: Text(
              regulation.fullTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  regulation.tipo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  regulation.descripcion,
                  style: TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(regulation.estado).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                regulation.estado,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(regulation.estado),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              close(context, regulation.id);
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'vigente':
        return AppColors.success;
      case 'derogada':
        return AppColors.error;
      case 'modificada':
        return AppColors.warning;
      default:
        return AppColors.textLight;
    }
  }
}
