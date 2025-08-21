import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/protected_area_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class AreasMapPage extends StatefulWidget {
  final String? selectedAreaId;

  const AreasMapPage({Key? key, this.selectedAreaId}) : super(key: key);

  @override
  _AreasMapPageState createState() => _AreasMapPageState();
}

class _AreasMapPageState extends State<AreasMapPage> {
  final ApiClient _apiClient = ApiClient();
  final Completer<GoogleMapController> _controller = Completer();

  List<ProtectedAreaModel> _areas = [];
  Set<Marker> _markers = {};
  ProtectedAreaModel? _selectedArea;
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;
  MapType _currentMapType = MapType.hybrid;

  // República Dominicana center coordinates
  static const LatLng _dominicanRepublicCenter = LatLng(18.7357, -70.1627);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedAreaId =
        widget.selectedAreaId ??
        ModalRoute.of(context)?.settings.arguments as String?;

    if (selectedAreaId != null && _areas.isNotEmpty) {
      _selectAreaById(selectedAreaId);
    }
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadProtectedAreas();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Silently handle location errors
    }
  }

  Future<void> _loadProtectedAreas() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(ApiConstants.protectedAreas);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> areasJson = response['data'];
        final areas = areasJson
            .map((json) => ProtectedAreaModel.fromJson(json))
            .where((area) => area.latitud != 0 && area.longitud != 0)
            .toList();

        setState(() {
          _areas = areas;
          _isLoading = false;
        });

        _createMarkers();

        // Select area if specified
        final selectedAreaId =
            widget.selectedAreaId ??
            ModalRoute.of(context)?.settings.arguments as String?;
        if (selectedAreaId != null) {
          _selectAreaById(selectedAreaId);
        }
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Error al cargar áreas protegidas';
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

  void _createMarkers() {
    final markers = _areas.map((area) {
      return Marker(
        markerId: MarkerId(area.id),
        position: LatLng(area.latitud, area.longitud),
        infoWindow: InfoWindow(
          title: area.nombre,
          snippet: area.tipo,
          onTap: () => _selectArea(area),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          area.visitasPermitidas
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueOrange,
        ),
        onTap: () => _selectArea(area),
      );
    }).toSet();

    // Add current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Ubicación actual',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _selectArea(ProtectedAreaModel area) {
    setState(() {
      _selectedArea = area;
    });

    _animateToArea(area);
    _showAreaBottomSheet(area);
  }

  void _selectAreaById(String areaId) {
    final area = _areas.firstWhere(
      (area) => area.id == areaId,
      orElse: () => _areas.first,
    );
    _selectArea(area);
  }

  Future<void> _animateToArea(ProtectedAreaModel area) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(area.latitud, area.longitud), zoom: 14.0),
      ),
    );
  }

  void _showAreaBottomSheet(ProtectedAreaModel area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    child: _buildAreaDetails(area),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAreaDetails(ProtectedAreaModel area) {
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
              ),
              child: Text(
                area.tipo,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            if (!area.visitasPermitidas)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ACCESO RESTRINGIDO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          area.nombre,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              area.ubicacion,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          area.descripcion,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        if (area.superficie != null) ...[
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.square_foot, size: 16, color: AppColors.textLight),
              SizedBox(width: 4),
              Text(
                'Superficie: ${area.superficieFormatted}',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ],
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/protected-area-detail',
                    arguments: area.id,
                  );
                },
                icon: Icon(Icons.info_outline),
                label: Text('Ver Detalles'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openDirections(area),
                icon: Icon(Icons.directions),
                label: Text('Cómo llegar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Áreas Protegidas'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
          IconButton(icon: Icon(Icons.layers), onPressed: _showMapTypeDialog),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidget(message: 'Cargando mapa...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadProtectedAreas,
      );
    }

    return Stack(
      children: [
        GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: CameraPosition(
            target: _currentPosition != null
                ? LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  )
                : _dominicanRepublicCenter,
            zoom: _currentPosition != null ? 10.0 : 8.0,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
        ),
        _buildLegend(),
        if (_areas.isNotEmpty) _buildAreasList(),
      ],
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leyenda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            _buildLegendItem(color: Colors.green, label: 'Visitas permitidas'),
            SizedBox(height: 4),
            _buildLegendItem(color: Colors.orange, label: 'Acceso restringido'),
            SizedBox(height: 4),
            _buildLegendItem(color: Colors.blue, label: 'Tu ubicación'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAreasList() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _areas.length,
          itemBuilder: (context, index) {
            final area = _areas[index];
            return _buildAreaListItem(area);
          },
        ),
      ),
    );
  }

  Widget _buildAreaListItem(ProtectedAreaModel area) {
    final isSelected = _selectedArea?.id == area.id;

    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: isSelected ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: AppColors.primaryGreen, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => _selectArea(area),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        area.tipo,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    if (!area.visitasPermitidas)
                      Icon(Icons.lock, size: 16, color: AppColors.warning),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  area.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  area.ubicacion,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  area.descripcion,
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          onPressed: _showAllAreas,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          heroTag: "show_all",
          child: Icon(Icons.zoom_out_map),
        ),
        SizedBox(height: 8),
        FloatingActionButton.small(
          onPressed: _goToCurrentLocation,
          backgroundColor: AppColors.secondaryBlue,
          foregroundColor: Colors.white,
          heroTag: "current_location",
          child: Icon(Icons.my_location),
        ),
      ],
    );
  }

  Future<void> _showAllAreas() async {
    if (_areas.isEmpty) return;

    final GoogleMapController controller = await _controller.future;

    // Calculate bounds to show all areas
    double minLat = _areas.first.latitud;
    double maxLat = _areas.first.latitud;
    double minLng = _areas.first.longitud;
    double maxLng = _areas.first.longitud;

    for (final area in _areas) {
      minLat = minLat < area.latitud ? minLat : area.latitud;
      maxLat = maxLat > area.latitud ? maxLat : area.latitud;
      minLng = minLng < area.longitud ? minLng : area.longitud;
      maxLng = maxLng > area.longitud ? maxLng : area.longitud;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      _createMarkers();
    }

    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 12.0,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo obtener la ubicación actual'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _showMapTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tipo de Mapa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Normal'),
                onTap: () {
                  _changeMapType(MapType.normal);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.satellite),
                title: Text('Satélite'),
                onTap: () {
                  _changeMapType(MapType.satellite);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.terrain),
                title: Text('Híbrido'),
                onTap: () {
                  _changeMapType(MapType.hybrid);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMapType(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
  }

  Future<void> _openDirections(ProtectedAreaModel area) async {
    final lat = area.latitud;
    final lng = area.longitud;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir las direcciones'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
