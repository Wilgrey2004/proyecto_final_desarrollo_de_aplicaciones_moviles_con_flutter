// lib/features/user_reports/presentation/pages/reports_map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/damage_report_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class ReportsMapPage extends StatefulWidget {
  @override
  _ReportsMapPageState createState() => _ReportsMapPageState();
}

class _ReportsMapPageState extends State<ReportsMapPage> {
  final ApiClient _apiClient = ApiClient();
  GoogleMapController? _mapController;

  List<DamageReportModel> _reports = [];
  List<DamageReportModel> _filteredReports = [];
  Set<Marker> _markers = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Filter state
  String _selectedEstado = 'Todos';
  String _selectedCategoria = 'Todas';
  List<String> _availableEstados = ['Todos'];
  List<String> _availableCategorias = ['Todas'];

  // Map configuration
  static const LatLng _dominicanRepublicCenter = LatLng(18.7357, -70.1627);
  static const double _defaultZoom = 8.0;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  void _checkAuthAndLoad() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _loadReports();
    } else {
      _showAuthRequiredDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Reportes'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _goToUserLocation,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "legend",
            onPressed: _showLegend,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryGreen,
            mini: true,
            child: Icon(Icons.info_outline),
          ),
          SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: "add_report",
            onPressed: () {
              Navigator.pushNamed(context, '/report-damage');
            },
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            icon: Icon(Icons.add),
            label: Text('Nuevo Reporte'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidget(message: 'Cargando mapa de reportes...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadReports,
      );
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Stack(
            children: [
              _buildMap(),
              if (_reports.isEmpty) _buildEmptyStateOverlay(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightGreen, AppColors.primaryGreen],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.map, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mapa de Reportes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${_filteredReports.length} reporte${_filteredReports.length != 1 ? 's' : ''} visible${_filteredReports.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _dominicanRepublicCenter,
        zoom: _defaultZoom,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      onTap: (LatLng position) {
        // Clear any selected markers
        setState(() {
          _updateMarkers();
        });
      },
    );
  }

  Widget _buildEmptyStateOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'No tienes reportes en el mapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cuando reportes daños ambientales, aparecerán aquí en el mapa.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
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
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();

    // If there are reports, fit bounds to show all markers
    if (_filteredReports.isNotEmpty) {
      _fitMarkersInView();
    }
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};

    for (final report in _filteredReports) {
      final markerId = MarkerId(report.id ?? report.titulo);
      final marker = Marker(
        markerId: markerId,
        position: LatLng(report.latitud, report.longitud),
        icon: _getMarkerIcon(report.estado),
        infoWindow: InfoWindow(
          title: report.titulo,
          snippet: '${report.estado} • ${report.fechaText}',
          onTap: () => _onMarkerTap(report),
        ),
        onTap: () => _onMarkerTap(report),
      );
      newMarkers.add(marker);
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  BitmapDescriptor _getMarkerIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case 'en proceso':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'resuelto':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'rechazado':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _onMarkerTap(DamageReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReportBottomSheet(report),
    );
  }

  Widget _buildReportBottomSheet(DamageReportModel report) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge and title
                  Row(
                    children: [
                      _buildStatusChip(report.estado),
                      SizedBox(width: 8),
                      if (report.codigoReporte != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.codigoReporte!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Text(
                    report.titulo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),

                  Text(
                    report.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Details row
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        report.fechaText,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      SizedBox(width: 16),
                      if (report.categoria != null) ...[
                        Icon(
                          Icons.category,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          report.categoria!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),

                  // Location info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.primaryGreen),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubicación',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              Text(
                                report.coordenadasText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (report.ubicacionDescripcion != null)
                                Text(
                                  report.ubicacionDescripcion!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/report-detail',
                              arguments: report.id,
                            );
                          },
                          icon: Icon(Icons.visibility),
                          label: Text('Ver Detalle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _centerMapOnReport(report);
                          },
                          icon: Icon(Icons.center_focus_strong),
                          label: Text('Centrar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text('Filtros'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedEstado,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableEstados.map((estado) {
                      return DropdownMenuItem(
                        value: estado,
                        child: Text(estado),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedEstado = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoria,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableCategorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCategoria = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedEstado = 'Todos';
                      _selectedCategoria = 'Todas';
                    });
                  },
                  child: Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLegend() {
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
              Text('Leyenda del Mapa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem('Pendiente', Colors.yellow, Icons.schedule),
              _buildLegendItem('En Proceso', Colors.blue, Icons.refresh),
              _buildLegendItem('Resuelto', Colors.green, Icons.check_circle),
              _buildLegendItem('Rechazado', Colors.red, Icons.cancel),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12),
          Icon(icon, size: 16, color: color),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _centerMapOnReport(DamageReportModel report) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(report.latitud, report.longitud),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Future<void> _goToUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage(
          'Los servicios de ubicación están desactivados',
          isError: true,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Permisos de ubicación denegados', isError: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Permisos de ubicación denegados permanentemente',
          isError: true,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      _showMessage('Error al obtener ubicación: $e', isError: true);
    }
  }

  void _fitMarkersInView() {
    if (_filteredReports.isEmpty || _mapController == null) return;

    double minLat = _filteredReports.first.latitud;
    double maxLat = _filteredReports.first.latitud;
    double minLng = _filteredReports.first.longitud;
    double maxLng = _filteredReports.first.longitud;

    for (final report in _filteredReports) {
      minLat = minLat < report.latitud ? minLat : report.latitud;
      maxLat = maxLat > report.latitud ? maxLat : report.latitud;
      minLng = minLng < report.longitud ? minLng : report.longitud;
      maxLng = maxLng > report.longitud ? maxLng : report.longitud;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      List<DamageReportModel> filtered = _reports;

      // Filter by estado
      if (_selectedEstado != 'Todos') {
        filtered = filtered
            .where((report) => report.estado == _selectedEstado)
            .toList();
      }

      // Filter by categoria
      if (_selectedCategoria != 'Todas') {
        filtered = filtered
            .where((report) => report.categoria == _selectedCategoria)
            .toList();
      }

      _filteredReports = filtered;
      _updateMarkers();

      if (_filteredReports.isNotEmpty) {
        _fitMarkersInView();
      }
    });
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
                'Necesitas iniciar sesión para ver el mapa de tus reportes.',
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

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(
        ApiConstants.reportsMap,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> reportsJson = response['data'];
        final reports = reportsJson
            .map((json) => DamageReportModel.fromJson(json))
            .toList();

        // Extract unique estados and categorias for filters
        final estados = reports
            .map((report) => report.estado)
            .where((estado) => estado.isNotEmpty)
            .toSet()
            .toList();
        estados.sort();

        final categorias = reports
            .map((report) => report.categoria)
            .where((categoria) => categoria != null && categoria.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();
        categorias.sort();

        setState(() {
          _reports = reports;
          _filteredReports = reports;
          _availableEstados = ['Todos', ...estados];
          _availableCategorias = ['Todas', ...categorias];
          _isLoading = false;
        });

        _updateMarkers();

        // Fit bounds if we have reports
        if (_filteredReports.isNotEmpty && _mapController != null) {
          _fitMarkersInView();
        }
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
