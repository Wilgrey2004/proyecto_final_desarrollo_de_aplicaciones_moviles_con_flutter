import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/protected_area_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class ProtectedAreaDetailPage extends StatefulWidget {
  final String? areaId;

  const ProtectedAreaDetailPage({Key? key, this.areaId}) : super(key: key);

  @override
  _ProtectedAreaDetailPageState createState() =>
      _ProtectedAreaDetailPageState();
}

class _ProtectedAreaDetailPageState extends State<ProtectedAreaDetailPage> {
  final ApiClient _apiClient = ApiClient();
  ProtectedAreaModel? _area;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAreaDetail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final areaId =
        widget.areaId ?? ModalRoute.of(context)?.settings.arguments as String?;
    if (areaId != null && areaId != _area?.id) {
      _loadAreaDetail();
    }
  }

  Future<void> _loadAreaDetail() async {
    final areaId =
        widget.areaId ?? ModalRoute.of(context)?.settings.arguments as String?;

    if (areaId == null) {
      setState(() {
        _errorMessage = 'ID de área protegida no válido';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(
        '${ApiConstants.protectedAreas}/$areaId',
      );

      if (response['success'] == true && response['data'] != null) {
        final areaData = response['data'];
        final area = ProtectedAreaModel.fromJson(areaData);

        setState(() {
          _area = area;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Error al cargar el área protegida';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _area != null ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: LoadingWidget(message: 'Cargando área protegida...'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: custom_error.ErrorWidget(
          message: _errorMessage!,
          onRetry: _loadAreaDetail,
        ),
      );
    }

    if (_area == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Área no encontrada'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('El área protegida no fue encontrada')),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _area!.imagen != null
            ? CachedNetworkImage(
                imageUrl: _area!.imagen!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.background,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.forestGreen, AppColors.primaryGreen],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.nature, size: 80, color: Colors.white),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.forestGreen, AppColors.primaryGreen],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.nature, size: 80, color: Colors.white),
                ),
              ),
      ),
      actions: [
        IconButton(icon: Icon(Icons.share), onPressed: _shareArea),
        IconButton(icon: Icon(Icons.map), onPressed: _openInMap),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _openDirections,
      backgroundColor: AppColors.primaryGreen,
      icon: Icon(Icons.directions, color: Colors.white),
      label: Text('Cómo llegar', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          _buildBasicInfo(),
          SizedBox(height: 20),
          _buildDescription(),
          if (_area!.actividades.isNotEmpty) ...[
            SizedBox(height: 20),
            _buildActivities(),
          ],
          if (_area!.flora.isNotEmpty || _area!.fauna.isNotEmpty) ...[
            SizedBox(height: 20),
            _buildBiodiversity(),
          ],
          if (_area!.horarios != null || _area!.tarifas != null) ...[
            SizedBox(height: 20),
            _buildVisitorInfo(),
          ],
          if (_area!.comoLlegar != null) ...[
            SizedBox(height: 20),
            _buildDirections(),
          ],
          if (_area!.sitioWeb != null || _area!.telefono != null) ...[
            SizedBox(height: 20),
            _buildContactInfo(),
          ],
          SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                _area!.tipo,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            if (!_area!.visitasPermitidas)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ACCESO RESTRINGIDO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          _area!.nombre,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              _area!.ubicacion,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          if (_area!.superficie != null)
            _buildInfoRow(
              icon: Icons.square_foot,
              label: 'Superficie',
              value: _area!.superficieFormatted,
            ),
          if (_area!.superficie != null && _area!.fechaCreacion != null)
            Divider(color: AppColors.divider),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Fecha de creación',
            value: _formatDate(_area!.fechaCreacion),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          _area!.descripcion,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividades',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _area!.actividades.map((actividad) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                actividad,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBiodiversity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biodiversidad',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        if (_area!.flora.isNotEmpty) ...[
          _buildBiodiversitySection(
            title: 'Flora',
            icon: Icons.local_florist,
            items: _area!.flora,
            color: AppColors.forestGreen,
          ),
          if (_area!.fauna.isNotEmpty) SizedBox(height: 16),
        ],
        if (_area!.fauna.isNotEmpty)
          _buildBiodiversitySection(
            title: 'Fauna',
            icon: Icons.pets,
            items: _area!.fauna,
            color: AppColors.earthBrown,
          ),
      ],
    );
  }

  Widget _buildBiodiversitySection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información para Visitantes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.skyBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              if (_area!.horarios != null) ...[
                _buildVisitorInfoRow(
                  icon: Icons.access_time,
                  label: 'Horarios',
                  value: _area!.horarios!,
                ),
                if (_area!.tarifas != null) SizedBox(height: 12),
              ],
              if (_area!.tarifas != null)
                _buildVisitorInfoRow(
                  icon: Icons.attach_money,
                  label: 'Tarifas',
                  value: _area!.tarifas!,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.skyBlue),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.skyBlue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo Llegar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Instrucciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _area!.comoLlegar!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Contacto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              if (_area!.telefono != null) ...[
                _buildContactRow(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  value: _area!.telefono!,
                  onTap: () => _launchPhone(_area!.telefono!),
                ),
                if (_area!.sitioWeb != null) SizedBox(height: 12),
              ],
              if (_area!.sitioWeb != null)
                _buildContactRow(
                  icon: Icons.web,
                  label: 'Sitio Web',
                  value: _area!.sitioWeb!,
                  onTap: () => _launchUrl(_area!.sitioWeb!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryGreen),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('No se puede abrir el enlace: $url');
      }
    } catch (e) {
      _showSnackBar('Error al abrir el enlace');
    }
  }

  Future<void> _launchPhone(String phone) async {
    try {
      final Uri uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('No se puede realizar la llamada');
      }
    } catch (e) {
      _showSnackBar('Error al realizar la llamada');
    }
  }

  void _openInMap() {
    Navigator.pushNamed(context, '/areas-map', arguments: _area!.id);
  }

  void _openDirections() async {
    final lat = _area!.latitud;
    final lng = _area!.longitud;

    try {
      // Try Google Maps first
      final googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      final Uri googleUri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to generic maps URL
        final genericUrl = 'https://maps.google.com/?q=$lat,$lng';
        final Uri genericUri = Uri.parse(genericUrl);
        await launchUrl(genericUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showSnackBar('Error al abrir las direcciones');
    }
  }

  void _shareArea() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de compartir no implementada'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
