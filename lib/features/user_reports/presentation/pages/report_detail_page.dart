// lib/features/user_reports/presentation/pages/report_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/damage_report_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class ReportDetailPage extends StatefulWidget {
  final String? reportId;

  const ReportDetailPage({Key? key, this.reportId}) : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final ApiClient _apiClient = ApiClient();
  DamageReportModel? _report;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReportDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detalle del Reporte'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (_report != null)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => _shareReport(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidget(message: 'Cargando detalle del reporte...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadReportDetail,
      );
    }

    if (_report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Reporte no encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusHeader(),
          _buildMainInfo(),
          _buildLocationSection(),
          if (_report!.fotoBase64 != null) _buildPhotoSection(),
          if (_report!.comentarioMinisterio != null)
            _buildMinistryCommentSection(),
          _buildTimelineSection(),
          _buildActionButtons(),
          SizedBox(height: 100), // Space for bottom padding
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor = _getStatusColor(_report!.estado);
    IconData statusIcon = _getStatusIcon(_report!.estado);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withOpacity(0.8), statusColor],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, size: 40, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            _report!.estado.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_report!.codigoReporte != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Código: ${_report!.codigoReporte}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _report!.titulo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Descripción', _report!.descripcion),
              if (_report!.categoria != null) ...[
                SizedBox(height: 12),
                _buildDetailRow('Categoría', _report!.categoria!),
              ],
              if (_report!.gravedad != null) ...[
                SizedBox(height: 12),
                _buildDetailRow('Gravedad', _report!.gravedad!),
              ],
              SizedBox(height: 12),
              _buildDetailRow('Fecha de reporte', _report!.fechaText),
              if (_report!.fechaActualizacion != null) ...[
                SizedBox(height: 12),
                _buildDetailRow(
                  'Última actualización',
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(_report!.fechaActualizacion!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Ubicación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailRow('Coordenadas', _report!.coordenadasText),
              if (_report!.ubicacionDescripcion != null) ...[
                SizedBox(height: 12),
                _buildDetailRow('Descripción', _report!.ubicacionDescripcion!),
              ],
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openInMaps,
                  icon: Icon(Icons.map),
                  label: Text('Ver en Mapa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.photo, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Evidencia Fotográfica',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  child: Image.memory(
                    base64Decode(_report!.fotoBase64!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.background,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: AppColors.error),
                              SizedBox(height: 8),
                              Text('Error al cargar imagen'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinistryCommentSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen.withOpacity(0.1),
                AppColors.lightGreen.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Comentario del Ministerio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                _report!.comentarioMinisterio!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Cronología',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTimelineItem(
                'Reporte creado',
                _report!.fechaText,
                Icons.add_circle,
                AppColors.primaryGreen,
                isCompleted: true,
              ),
              if (_report!.estado != 'Pendiente')
                _buildTimelineItem(
                  'En revisión',
                  _report!.fechaActualizacion != null
                      ? DateFormat(
                          'dd/MM/yyyy',
                        ).format(_report!.fechaActualizacion!)
                      : 'En proceso',
                  Icons.visibility,
                  AppColors.secondaryBlue,
                  isCompleted: true,
                ),
              if (_report!.estado == 'Resuelto')
                _buildTimelineItem(
                  'Resuelto',
                  _report!.fechaActualizacion != null
                      ? DateFormat(
                          'dd/MM/yyyy',
                        ).format(_report!.fechaActualizacion!)
                      : 'Completado',
                  Icons.check_circle,
                  AppColors.success,
                  isCompleted: true,
                  isLast: true,
                ),
              if (_report!.estado == 'Rechazado')
                _buildTimelineItem(
                  'Rechazado',
                  _report!.fechaActualizacion != null
                      ? DateFormat(
                          'dd/MM/yyyy',
                        ).format(_report!.fechaActualizacion!)
                      : 'Rechazado',
                  Icons.cancel,
                  AppColors.error,
                  isCompleted: true,
                  isLast: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    bool isCompleted = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? color : color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            if (!isLast)
              Container(width: 2, height: 32, color: color.withOpacity(0.3)),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textLight,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyReportCode,
                  icon: Icon(Icons.copy),
                  label: Text('Copiar Código'),
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
                  onPressed: _shareReport,
                  icon: Icon(Icons.share),
                  label: Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_report!.estado == 'Pendiente') ...[
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _editReport,
                icon: Icon(Icons.edit),
                label: Text('Editar Reporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
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

  Future<void> _openInMaps() async {
    final url =
        'https://www.google.com/maps?q=${_report!.latitud},${_report!.longitud}';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('No se pudo abrir el mapa', isError: true);
    }
  }

  void _copyReportCode() {
    if (_report!.codigoReporte != null) {
      Clipboard.setData(ClipboardData(text: _report!.codigoReporte!));
      _showMessage('Código copiado al portapapeles', isError: false);
    }
  }

  void _shareReport() {
    final text =
        '''
Reporte de Daño Ambiental

Título: ${_report!.titulo}
Código: ${_report!.codigoReporte ?? 'N/A'}
Estado: ${_report!.estado}
Fecha: ${_report!.fechaText}
Ubicación: ${_report!.coordenadasText}

Descripción: ${_report!.descripcion}
''';

    // Copy to clipboard as sharing functionality
    Clipboard.setData(ClipboardData(text: text));
    _showMessage(
      'Información del reporte copiada al portapapeles',
      isError: false,
    );
  }

  void _editReport() {
    // Navigate to edit report page (you may need to implement this)
    _showMessage('Función de edición en desarrollo', isError: false);
  }

  Future<void> _loadReportDetail() async {
    final String reportId =
        widget.reportId ??
        ModalRoute.of(context)?.settings.arguments as String? ??
        '';

    if (reportId.isEmpty) {
      setState(() {
        _errorMessage = 'ID de reporte no válido';
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
        '${ApiConstants.myReports}/$reportId',
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _report = DamageReportModel.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar el reporte';
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

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
